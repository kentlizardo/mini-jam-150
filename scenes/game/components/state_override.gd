class_name StateOverride extends State

var last_state : State

func _init(last_state : State) -> void:
	self.last_state = last_state

func exit_state() -> void:
	last_state.state_machine.state = last_state

