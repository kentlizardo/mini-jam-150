extends Area3D

@export var owner_groups : Array[String] = []
@export var damage: int = 1

var sender : Node

func _on_area_entered(area: Area3D) -> void:
	if is_queued_for_deletion():
		return
	hit_check(area)
	
func _on_body_entered(body: Node3D) -> void:
	if is_queued_for_deletion():
		return
	hit_check(body)

func hit_check(node: Node3D) -> void:
	print(node.name)
	if !node.is_in_group("player"):
		if node.has_method("damage"):
			node.damage(damage, Global.DamageType.PHYSICAL, sender)
			#self.queue_free()
			if sender is Player:
				(sender.walk_pivot as ShakeWeapon).add_trauma(50.0 * damage)
				(sender.camera as ShakeCamera).add_trauma(25.0 * damage)
				Game.current.short_pause(0.1 * damage)

#func _ready() -> void:
	#kill()
#func kill() -> void:
	#await get_tree().create_timer(0.01).timeout
	#queue_free()

