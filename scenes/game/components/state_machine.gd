class_name StateMachine extends Node

@export var initial_state : State

var state : State:
	set(x):
		if state:
			state.exit()
		state = x
		if state:
			state.enter(get_parent())

func _ready() -> void:
	if !get_parent().is_node_ready():
		await get_parent().ready
	state = initial_state
