extends Area3D

@export var light_proj : LightProjectile
@export var rend_sound: AudioStreamPlayer3D
@export var absorb_sound: AudioStreamPlayer3D

func _on_area_3d_area_entered(area: Area3D) -> void:
	_hit_check(area)

func _on_area_3d_body_entered(body: Node3D) -> void:
	_hit_check(body)

func _hit_check(node: Node3D) -> void:
	if node == light_proj.gravitate_towards:
		if node is Player:
			Util.preserve_and_oneshot_sound(absorb_sound)
			node.absorb_light(light_proj)
			light_proj.queue_free()
	if node == self or node is LightProjectile:
		return
	if light_proj.sender == node:
		return
	if light_proj.fast_sprite.visible:
		if node.has_method("damage"):
			node.damage(1, Global.DamageType.MAGIC, light_proj)
			ShakeCamera.current_cam.add_trauma(10.0)
			#light_proj.queue_free()
			light_proj.health -= 1
			light_proj.damage_check()
			rend_sound.play()
	else:
		if node is Lighteater:
			node.damage(1, Global.DamageType.MAGIC, light_proj)
			Util.preserve_and_oneshot_sound(absorb_sound)
			light_proj.queue_free()
