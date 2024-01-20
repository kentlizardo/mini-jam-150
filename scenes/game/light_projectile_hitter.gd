extends Area3D

@export var light_proj : LightProjectile

func _on_area_3d_area_entered(area: Area3D) -> void:
	_hit_check(area)

func _on_area_3d_body_entered(body: Node3D) -> void:
	_hit_check(body)

func _hit_check(node: Node3D) -> void:
	if node == self or node is LightProjectile:
		return
	if !node.is_in_group("player"):
		if node.has_method("damage"):
			node.damage(2, Global.DamageType.MAGIC, self)
	if node == light_proj.gravitate_towards:
		if node is Player:
			node.absorb_light(light_proj)
