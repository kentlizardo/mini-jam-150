class_name BirdLightProjectile extends LightProjectile
# removed functionality for simplicity

func _ready() -> void:
	await get_tree().create_timer(1.0)
	queue_free()
