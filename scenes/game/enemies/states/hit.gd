extends StateOverride

@export var stun_length := 0.3

func _enter() -> void:
	await get_tree().create_timer(stun_length).timeout
	exit_state()
