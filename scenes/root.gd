class_name Root extends Node

@export var pause_menu: Control

static var current: Root
func _init() -> void:
	current = self

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().paused = !get_tree().paused
		pause_menu.visible = get_tree().paused
		get_viewport().set_input_as_handled()
