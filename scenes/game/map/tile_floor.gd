class_name TileFloor extends Node3D

signal entered

@export var area: Area3D

func _ready() -> void:
	area.body_entered.connect(_on_area_entered)

func _on_area_entered(body: Node3D) -> void:
	if body is Player:
		entered.emit()
