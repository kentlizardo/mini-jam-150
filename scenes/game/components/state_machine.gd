class_name StateMachine extends Node

@export var initial_state : State

var holder : Node:
	get:
		return get_parent()

var state : State:
	set(x):
		if state:
			state.exit()
		state = x
		if state:
			state.enter(self)

func _ready() -> void:
	if !holder.is_node_ready():
		await holder.ready
	state = initial_state
