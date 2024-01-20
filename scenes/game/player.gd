class_name Player extends CharacterBody3D

const SLASH_PROJECTILE_TEMPLATE = preload("res://scenes/game/slash_projectile.tscn")
const LIGHT_PROJECTILE_TEMPLATE = preload("res://scenes/game/light_projectile.tscn")
const SPEED = 10.0

@export var camera : Camera3D
@export var camera_forward : Node3D

@export var mace_anim_player: AnimationPlayer
@export var light_anim_player: AnimationPlayer
@export var walk_pivot : Node2D

func _init() -> void:
	add_to_group("player")

func _ready() -> void:
	_capture_mouse()

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
		print(mace_anim_player)
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

func _attack() -> void:
	var slash := SLASH_PROJECTILE_TEMPLATE.instantiate()
	slash.sender = self
	camera.add_child(slash)
var charged := false
func _charge() -> void:
	charged = true

const SHAKE_FRAME_LEN := 1.0 / 30
var _shake_timer := 0.0
var shake_amount := 0
func _process(delta: float) -> void:
	if shake_amount > 0:
		_shake_timer += delta
		if _shake_timer > SHAKE_FRAME_LEN:
			_shake_timer = 0.0
			walk_pivot.position = Vector2(randi_range(-shake_amount, shake_amount), randi_range(-shake_amount, shake_amount))
	else:
		walk_pivot.position = Vector2.ZERO
