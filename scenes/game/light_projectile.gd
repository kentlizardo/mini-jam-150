class_name LightProjectile extends RigidBody3D

const HIT_SPEED = 40.0
const GRAVITATION_SPEED = 30.0

var gravitate_towards : Node3D

func damage(damage: int, damage_type: Global.DamageType, sender: Node) -> void:
	if sender is Player:
		var move := Vector3(sender.camera_forward.global_position - sender.camera.global_position)
		apply_central_impulse(move.normalized() * HIT_SPEED)

func _physics_process(delta: float) -> void:
	if is_instance_valid(gravitate_towards):
		var move := Vector3(gravitate_towards.global_position - global_position)
		apply_central_force(move.normalized() * GRAVITATION_SPEED)
	print(linear_velocity)

func _on_area_3d_area_entered(area: Area3D) -> void:
	_hit_check(area)

func _on_area_3d_body_entered(body: Node3D) -> void:
	_hit_check(body)

func _hit_check(node: Node3D) -> void:
	if node == self or node is LightProjectile:
		return
	if !node.is_in_group("player"):
		if node.has_method("damage"):
			node.damage(2, Global.DamageType.MAGIC, self)
			queue_free()
	if node == gravitate_towards:
		if node is Player:
			node.absorb_light(self)
