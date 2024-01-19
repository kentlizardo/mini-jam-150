extends State

func _enter() -> void:
	if entity_holder.animation_player.has_animation("search"):
		entity_holder.animation_player.play("search")

func _exit() -> void:
	pass

const SPEED = 2
func _physics_process(delta: float) -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player is Node3D:
		if holder is CharacterBody3D:
			var move := Vector3(player.global_position - holder.global_position)
			move.y = 0
			if move:
				holder.velocity.x = move.x * SPEED
				holder.velocity.z = move.z * SPEED
			else:
				holder.velocity.x = move_toward(holder.velocity.x, 0, SPEED)
				holder.velocity.z = move_toward(holder.velocity.z, 0, SPEED)
	holder.move_and_slide()
