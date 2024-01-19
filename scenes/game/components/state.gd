class_name State extends Node

var state_machine: StateMachine:
	get:
		return get_parent() as StateMachine
var holder: Node:
	get:
		return state_machine.holder
var entity_holder: Entity:
	get:
		return holder as Entity

func _enter() -> void:
	Debug.abstr_func(self)

func _exit() -> void:
	Debug.abstr_func(self)

func push() -> void:
	state_machine.state = self

func enter() -> void:
	set_process(true)
	set_physics_process(true)
	_enter()

func exit() -> void:
	_exit()
	set_process(false)
	set_physics_process(false)
