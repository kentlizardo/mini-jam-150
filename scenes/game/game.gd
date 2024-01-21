class_name Game extends Node

static var current : Game

func _enter_tree() -> void:
	current = self

func short_pause() -> void:
	get_tree().paused = true
	await get_tree().create_timer(0.1).timeout
	get_tree().paused = false

