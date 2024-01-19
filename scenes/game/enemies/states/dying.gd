extends State

func _enter() -> void:
	if entity_holder:
		if entity_holder.animation_player.has_animation("dying"):
			entity_holder.animation_player.play("dying")
			await entity_holder.animation_player.animation_finished
	holder.queue_free()
