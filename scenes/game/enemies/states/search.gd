extends State

@export var vis: Vision

func _enter() -> void:
	pass
func _exit() -> void:
	pass

const SPEED = 1
func _physics_process(delta: float) -> void:
	var gob := entity_holder as Goblin
	if gob:
		var player_target : Player
		for i in vis.seen:
			if i is Player:
				player_target = i
		var move := Vector3.ZERO
		if player_target:
			move = (player_target.global_position - gob.global_position).normalized()
		if move:
			holder.velocity.x = move.x * SPEED
			holder.velocity.z = move.z * SPEED
		else:
			holder.velocity.x = move_toward(holder.velocity.x, 0, SPEED)
			holder.velocity.z = move_toward(holder.velocity.z, 0, SPEED)
		holder.move_and_slide()
