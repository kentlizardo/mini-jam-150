class_name LightProjectile extends RigidBody3D

signal transmuted(next_light: Node3D)

const HIT_SPEED = 60.0
const GRAVITATION_SPEED = 40.0

@export var normal_sprite: Sprite3D
@export var fast_sprite: Sprite3D

var gravitate_towards: Node3D

func damage(damage: int, damage_type: Global.DamageType, sender: Node) -> void:
	if sender is Player:
		var move := Vector3(sender.camera_forward.global_position - sender.camera.global_position)
		apply_central_impulse(move.normalized() * HIT_SPEED * damage)
	if sender is LightProjectile:
		push_error("Create stun")

func _physics_process(delta: float) -> void:
	if is_instance_valid(gravitate_towards):
		var move := Vector3(gravitate_towards.global_position - global_position)
		apply_central_force(move.normalized() * GRAVITATION_SPEED)
	if linear_velocity.length_squared() >= 35 * 35 * delta:
		normal_sprite.visible = false
		fast_sprite.visible = true
	else:
		fast_sprite.visible = false
		normal_sprite.visible = true

func dispel_light() -> void:
	queue_free()
