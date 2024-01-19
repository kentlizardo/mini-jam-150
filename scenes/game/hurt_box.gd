class_name HurtBox extends Area3D

@export var defense := 0

signal damaged(damage: int)

func damage(damage: int, damage_type: Global.DamageType, sender: Node) -> void:
	damaged.emit(maxi(damage - defense, 0))
