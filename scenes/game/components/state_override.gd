class_name StateOverride extends State

var last_state : State

func push() -> void:
	last_state = state_machine.state
	super()

func exit_state() -> void:
	last_state.state_machine.state = last_state

