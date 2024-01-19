class_name State extends Node

var state_machine: StateMachine
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

func enter(state_machine : StateMachine) -> void:
	self.state_machine = state_machine
	set_process(true)
	set_process(true)
	_enter()

func exit() -> void:
	_exit()
	state_machine = null
	set_process(false)
