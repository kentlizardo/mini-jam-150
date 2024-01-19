class_name Health extends Node

signal damage_taken(damage: int)
signal die
signal hurt

@export var health := 1
@export var max_health := -1

func damage(value: int) -> void:
	health -= value
	if !damage_check():
		hurt.emit()

func damage_check() -> bool:
	if health <= 0:
		die.emit()
		return true
	return false
