class_name Player extends CharacterBody3D

const SLASH_PROJECTILE_TEMPLATE = preload("res://scenes/game/slash_projectile.tscn")
const LIGHT_PROJECTILE_TEMPLATE = preload("res://scenes/game/light_projectile.tscn")
const SPEED = 5.0

@export var camera : ShakeCamera
@export var camera_forward : Node3D

@export var mace_anim_player: AnimationPlayer
@export var light_anim_player: AnimationPlayer
@export var walk_pivot : ShakeWeapon

var able_to_slash : Array[Node3D] = []

func _init() -> void:
	add_to_group("player")

func _ready() -> void:
	_capture_mouse()

func damage(damage: int, damage_type: Global.DamageType, sender: Node) -> void:
	print("Player damaged")
	camera.add_trauma(5.0)

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
		mace_anim_player.play("mace_attack")
		get_viewport().set_input_as_handled()
	if Input.is_action_just_pressed("secondary"):
		if !is_instance_valid(light_proj):
			start_light()
		else:
			start_recall()
		get_viewport().set_input_as_handled()
	if Input.is_action_just_released("secondary"):
		if !is_instance_valid(light_proj):
			release_light()
		else:
			stop_recall()
		get_viewport().set_input_as_handled()

func _capture_mouse() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	Input.warp_mouse(get_window().size / 2)
func _uncapture_mouse() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

var light_proj : LightProjectile
func start_light() -> void:
	light_anim_player.stop()
	light_anim_player.play("light_summon")
func release_light() -> void:
	light_anim_player.stop()
	if charged:
		charged = false
		light_proj = LIGHT_PROJECTILE_TEMPLATE.instantiate() as LightProjectile
		get_parent().add_child(light_proj)
		light_proj.global_position = camera_forward.global_position
		light_proj.linear_velocity = get_real_velocity()
func start_recall() -> void:
	light_proj.gravitate_towards = self
func stop_recall() -> void:
	light_proj.gravitate_towards = null
func absorb_light(light: LightProjectile) -> void:
	if light_proj == light and light.gravitate_towards == self:
		light_proj = null
		light.queue_free()

func _attack(damage: int) -> void:
	print(able_to_slash)
	var slashing : Node
	var dist := -1
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
	if !slashing.is_in_group("player"):
		print(slashing.has_method("damage"))
		if slashing.has_method("damage"):
			print("boom?")
			slashing.damage(damage, Global.DamageType.PHYSICAL, self)
			walk_pivot.add_trauma(50.0 * damage)
			camera.add_trauma(25.0 * damage)
			Game.current.short_pause(0.1 * damage)
	#var slash := SLASH_PROJECTILE_TEMPLATE.instantiate()
	#slash.sender = self
	#add_child(slash)
	#slash.global_position = camera.global_position
	#slash.global_rotation = camera.global_rotation
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
