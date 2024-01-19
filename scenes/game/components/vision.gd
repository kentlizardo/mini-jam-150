extends Node

@export var initial_areas : Array[Area3D] = []

func _ready() -> void:
	initial_areas.all(add_vision)

func add_vision(area: Area3D) -> void:
	area.area_entered.connect(_vision_on_area_entered)
	area.area_exited.connect(_vision_on_area_exited)
func remove_vision(area: Area3D) -> void:
	area.area_entered.disconnect(_vision_on_area_entered)
	area.area_exited.disconnect(_vision_on_area_exited)

func _vision_on_area_entered(area: Area3D) -> void:
	pass
func _vision_on_area_exited(area: Area3D) -> void:
	pass
