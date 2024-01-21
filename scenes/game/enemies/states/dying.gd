extends State

func _enter() -> void:
	for node: Node in holder.get_children():
		if node is Area3D:
			node.queue_free()
	if entity_holder:
		if entity_holder.sprite:
			var frames := entity_holder.sprite.sprite_frames
			if frames.has_animation("dying"):
				entity_holder.sprite.play("dying")
				await entity_holder.sprite.animation_finished
		var tw := (entity_holder.sprite as SpriteBase3D).create_tween()
		tw.tween_property((entity_holder.sprite as SpriteBase3D), "modulate:a", 0.0, 0.8).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
		await tw.finished
	holder.queue_free()
