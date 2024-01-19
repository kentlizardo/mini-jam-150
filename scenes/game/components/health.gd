class_name Health extends Node

signal damage_taken(damage: int)
signal die

@export var health := 1
@export var max_health := -1

func damage(value: int) -> void:
	health -= value
	damage_check()

func damage_check() -> void:
	if health <= 0:
		die.emit()
