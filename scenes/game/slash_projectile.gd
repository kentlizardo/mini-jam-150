extends Area3D

@export var owner_groups : Array[String] = []
@export var damage: int = 1

var sender : Node

func _on_area_entered(area: Area3D) -> void:
	if is_queued_for_deletion():
		return
	if !area.is_in_group("player"):
		if area.has_method("damage"):
			area.damage(damage, Global.DamageType.PHYSICAL, sender)
			queue_free()

func _ready() -> void:
	kill()
func kill() -> void:
	await get_tree().create_timer(0.1).timeout
	queue_free()
