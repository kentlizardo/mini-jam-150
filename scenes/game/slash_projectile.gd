extends Area3D

@export var owner_groups : Array[String] = []
@export var damage: int = 1

func _on_area_entered(area: Area3D) -> void:
	if area is HurtBox:
		area.damage(damage, Global.DamageType.PHYSICAL)
		queue_free()

func _ready() -> void:
	kill()
func kill() -> void:
	await get_tree().create_timer(0.1).timeout
	queue_free()
