class_name Player extends CharacterBody3D

static var SLASH_PROJECTILE_TEMPLATE := load("res://scenes/game/slash_projectile.tscn") as PackedScene
static var LIGHT_PROJECTILE_TEMPLATE := load("res://scenes/game/light_projectile.tscn") as PackedScene
const SPEED = 5.0

@export var camera : ShakeCamera
@export var camera_forward : Node3D

@export var mace_anim_player: AnimationPlayer
@export var light_anim_player: AnimationPlayer
@export var walk_pivot : ShakeWeapon

var able_to_slash : Array[Node3D] = []
var health := 5

func _init() -> void:
	add_to_group("player")
	current_player = self

static var current_player : Player
func _ready() -> void:
	_capture_mouse()

func damage(damage: int, damage_type: Global.DamageType, source: Node) -> void:
	camera.add_trauma(35.0)
	health -= 1

func _physics_process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			_uncapture_mouse()
			get_viewport().set_input_as_handled()
	if event is InputEventMouseButton:
		if event.pressed:
			if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
				_capture_mouse()
				get_viewport().set_input_as_handled()
	if event is InputEventMouseMotion:
		var x_delta : float = event.relative.x
		rotate_y(-x_delta * 0.01)
	if Input.is_action_just_pressed("primary"):
		start_combo()
		get_viewport().set_input_as_handled()
	if Input.is_action_just_pressed("secondary"):
		if is_instance_valid(light_proj):
			start_recall()
		else:
			if personal_light:
				var tw := personal_light_sprite.create_tween()
				tw.tween_property(personal_light_sprite, "target_position", PersonalLightSprite.HIT_POS, 0.5).from_current().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUINT)
			else:
				start_light()
		get_viewport().set_input_as_handled()
	if Input.is_action_just_released("secondary"):
		if is_instance_valid(light_proj):
			stop_recall()
		else:
			if personal_light:
				var tw := personal_light_sprite.create_tween()
				tw.tween_property(personal_light_sprite, "target_position", Vector2.ZERO, 0.5).from_current().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUINT)
			else:
				release_light()
		get_viewport().set_input_as_handled()
	if Input.is_action_just_pressed("dispel"):
		if is_instance_valid(light_proj):
			dispel_light()
		else:
			if personal_light:
				personal_light = false
		get_viewport().set_input_as_handled()

func _capture_mouse() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	Input.warp_mouse(get_window().size / 2)
func _uncapture_mouse() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

var light_proj : Node3D:
	set(x):
		if is_instance_valid(light_proj):
			if light_proj.has_signal("transmuted"):
				light_proj.transmuted.disconnect(_on_transmute)
		light_proj = x
		if is_instance_valid(light_proj):
			if light_proj.has_signal("transmuted"):
				light_proj.transmuted.connect(_on_transmute)
func _on_transmute(next_light: Node3D) -> void:
	light_proj = next_light

@export var personal_light_sprite : PersonalLightSprite
@export var fake_light : FakeLight
var personal_light := false:
	set(x):
		personal_light = x
		personal_light_sprite.position = Vector2.ZERO
		personal_light_sprite.target_position = Vector2.ZERO
		personal_light_sprite.visible = personal_light
		fake_light.radius = 5.0 if personal_light else 3.0
func start_light() -> void:
	light_anim_player.stop()
	light_anim_player.play("light_summon")
func release_light() -> void:
	light_anim_player.stop()
	if charged:
		personal_light = true
		charged = false
func send_light() -> void:
	light_anim_player.stop()
	light_proj = LIGHT_PROJECTILE_TEMPLATE.instantiate() as LightProjectile
	light_proj.sender = self
	get_parent().add_child(light_proj)
	light_proj.global_position = camera_forward.global_position
	light_proj.linear_velocity = get_real_velocity()
	light_proj.apply_central_impulse((camera_forward.global_position - global_position).normalized() * LightProjectile.HIT_SPEED)
func start_recall() -> void:
	if light_proj is Lantern:
		light_proj.recall()
	if light_proj is LightProjectile:
		light_proj.gravitate_towards = self
func stop_recall() -> void:
	if light_proj is LightProjectile:
		light_proj.gravitate_towards = null
func absorb_light(light: LightProjectile) -> void:
	if light_proj == light and light.gravitate_towards == self:
		light_proj = null
func dispel_light() -> void:
	if is_instance_valid(light_proj):
		if light_proj.has_method("dispel_light"):
			light_proj.dispel_light()
		else:
			push_error("Should not have a light_proj that cannot dispel light.")
		light_proj = null

var combo := ""
var combo_chain := {
	"attack_1": "attack_2",
	"attack_2": "attack_3",
}
func start_combo() -> void:
	if mace_anim_player.is_playing():
		if !combo.is_empty():
			mace_anim_player.play(combo)
	else:
		combo = ""
		mace_anim_player.play("attack_1")
func _attack(damage: int) -> void:
	if personal_light:
		if personal_light_sprite.position.distance_to(PersonalLightSprite.HIT_POS) <= 20.0:
			send_light()
			personal_light = false
			walk_pivot.add_trauma(50.0 * damage)
			camera.add_trauma(25.0 * damage)
			Game.current.short_pause(0.1 * damage)
			return
	var slashing : Node
	var dist := -1
	var attacked := false
	for i in able_to_slash:
		if !slashing:
			slashing = i
			dist = i.global_position.distance_to(global_position)
		else:
			var compare_dist := i.global_position.distance_to(global_position)
			if compare_dist < dist:
				slashing = i
				dist = compare_dist
	if !slashing:
		return
	if slashing != self:
		if slashing.has_method("damage"):
			slashing.damage(damage, Global.DamageType.PHYSICAL, self)
			attacked = true
	if attacked:
		walk_pivot.add_trauma(50.0 * damage)
		camera.add_trauma(25.0 * damage)
		Game.current.short_pause(0.1 * damage)
		if combo_chain.has(mace_anim_player.current_animation):
			combo = combo_chain[mace_anim_player.current_animation] as String
			print("next current chain " + combo)
		else:
			combo = "attack_1"
			print("next current chain " + combo)
	#var slash := SLASH_PROJECTILE_TEMPLATE.instantiate()
	#slash.sender = self
	#add_child(slash)
	#slash.global_position = camera.global_position
	#slash.global_rotation = camera.global_rotation
func _reset_combo() -> void:
	combo = ""

var charged := false
func _charge() -> void:
	charged = true

func slash_check(node: Node3D) -> void:
	if node == self:
		return
	if !able_to_slash.has(node) and node.has_method("damage"):
		able_to_slash.append(node)
func remove_check(node: Node3D) -> void:
	if able_to_slash.has(node):
		able_to_slash.remove_at(able_to_slash.find(node))

func _on_slash_area_3d_area_entered(area: Area3D) -> void:
	slash_check(area)
func _on_slash_area_3d_area_exited(area: Area3D) -> void:
	remove_check(area)
func _on_slash_area_3d_body_entered(body: Node3D) -> void:
	slash_check(body)
func _on_slash_area_3d_body_exited(body: Node3D) -> void:
	remove_check(body)
