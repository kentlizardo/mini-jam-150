class_name Vision extends Area3D

var seen : Array[Node3D] = []

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node3D) -> void:
	if get_parent_node_3d():
		if body == get_parent_node_3d():
			return
	seen.append(body)
func _on_body_exited(body: Node3D) -> void:
	var x := seen.find(body)
	if x != -1:
		seen.remove_at(x)
