class_name Player extends CharacterBody3D

const SLASH_PROJECTILE_TEMPLATE = preload("res://scenes/game/slash_projectile.tscn")
const LIGHT_PROJECTILE_TEMPLATE = preload("res://scenes/game/light_projectile.tscn")
const SPEED = 5.0

@export var camera : Camera3D
@export var camera_forward : Node3D
@export var mace_anim_player : AnimationPlayer
@export var light_anim_player : AnimationPlayer

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
		mace_anim_player.play("mace_attack")
		get_viewport().set_input_as_handled()
	if Input.is_action_just_pressed("secondary"):
		start_light()
		get_viewport().set_input_as_handled()
	if Input.is_action_just_released("secondary"):
		release_light()
		get_viewport().set_input_as_handled()

func _capture_mouse() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	Input.warp_mouse(get_window().size / 2)
func _uncapture_mouse() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func start_light() -> void:
	light_anim_player.stop()
	light_anim_player.play("light_summon")

func release_light() -> void:
	light_anim_player.stop()
	if charged:
		charged = false
		var light := LIGHT_PROJECTILE_TEMPLATE.instantiate() as Node3D
		light.global_position = camera_forward.global_position
		get_parent().add_child(light)

func _attack() -> void:
	var slash := SLASH_PROJECTILE_TEMPLATE.instantiate()
	slash.sender = self
	camera.add_child(slash)
var charged := false
func _charge() -> void:
	charged = true
