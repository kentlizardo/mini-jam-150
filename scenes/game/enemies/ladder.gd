class_name Ladder extends Node3D

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Player:
		get_node("/root/Root").add_child(load("res://end_screen.tscn").instantiate())
