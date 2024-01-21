class_name FakeLight extends Node3D

@export var radius := 5.0
var last_position : Vector3

func _ready() -> void:
	last_position = global_position

func _enter_tree() -> void:
	LightHelper.add_light(self)

func _exit_tree() -> void:
	LightHelper.remove_light(self)

func _physics_process(delta: float) -> void:
	if last_position != global_position:
		LightHelper.set_dirty()
	last_position = global_position
