extends CharacterBody3D

const SPEED = 5.0

var drive_vector := Vector3.ZERO

func _physics_process(delta: float) -> void:
	var direction := drive_vector.normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
