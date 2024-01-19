class_name State extends Node

var holder : Node
var entity_holder : Entity:
	get:
		return holder as Entity

func _enter() -> void:
	Debug.abstr_func(self)

func _exit() -> void:
	Debug.abstr_func(self)

func enter(new_holder : Node) -> void:
	holder = new_holder
	set_process(true)
	_enter()

func exit() -> void:
	holder = null
	set_process(false)
	_exit()
