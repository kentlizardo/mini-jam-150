extends Area3D

const PROJ_SPEED = 2.0

var speed := Vector3.ZERO

func damage(damage: int, damage_type: Global.DamageType, sender: Node) -> void:
	if sender is Player:
		var move := Vector3(global_position - sender.global_position)
		speed = move.normalized()

func _physics_process(delta: float) -> void:
	global_position += PROJ_SPEED * speed

func _on_area_entered(area: Area3D) -> void:
	pass
