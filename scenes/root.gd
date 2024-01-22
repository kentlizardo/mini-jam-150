class_name Root extends Node

static var current: Root
func _init() -> void:
	current = self

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().paused = !get_tree().paused
		get_viewport().set_input_as_handled()
