extends State

func _enter() -> void:
	if entity_holder.animation_player.has_animation("search"):
		entity_holder.animation_player.play("search")

func _exit() -> void:
	pass

func _physics_process(delta: float) -> void:
	pass
