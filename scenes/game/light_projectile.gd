extends RigidBody3D

const HIT_SPEED = 10.0

func damage(damage: int, damage_type: Global.DamageType, sender: Node) -> void:
	if sender is Player:
		var move := Vector3(global_position - sender.global_position)
		apply_central_impulse(move.normalized() * HIT_SPEED)

func _on_area_entered(area: Area3D) -> void:
	pass
