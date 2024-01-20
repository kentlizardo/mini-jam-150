class_name LightProjectile extends RigidBody3D

const FAST_SPRITE := preload("res://assets/textures/light_fast.png")
const NORMAL_SPRITE := preload("res://assets/textures/light.png")
const HIT_SPEED = 40.0
const GRAVITATION_SPEED = 30.0

@export var sprite: Sprite3D

var gravitate_towards: Node3D

func damage(damage: int, damage_type: Global.DamageType, sender: Node) -> void:
	if sender is Player:
		var move := Vector3(sender.camera_forward.global_position - sender.camera.global_position)
		apply_central_impulse(move.normalized() * HIT_SPEED)

func _physics_process(delta: float) -> void:
	if is_instance_valid(gravitate_towards):
		var move := Vector3(gravitate_towards.global_position - global_position)
		apply_central_force(move.normalized() * GRAVITATION_SPEED)
	if linear_velocity.length_squared() >= 35 * 35 * delta:
		sprite.texture = FAST_SPRITE
	else:
		sprite.texture = NORMAL_SPRITE
