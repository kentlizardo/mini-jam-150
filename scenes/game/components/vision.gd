extends Area3D

var seen : Array[Node3D] = []

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node3D) -> void:
	seen.append(body)
func _on_body_exited(body: Node3D) -> void:
	seen.remove_at(seen.find(body))
