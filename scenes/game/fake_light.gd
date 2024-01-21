class_name FakeLight extends Node3D

@export var radius := 5.0:
	set(x):
		if !is_node_ready():
			await ready
		if col:
			var shape := SphereShape3D.new()
			shape.radius = x
			col.shape = shape

@export var col : CollisionShape3D

var last_position : Vector3

func _ready() -> void:
	last_position = global_position
	print("actually reeadied")
	print(col)

func _enter_tree() -> void:
	LightHelper.add_light(self)

func _exit_tree() -> void:
	LightHelper.remove_light(self)

func _physics_process(delta: float) -> void:
	if last_position != global_position:
		LightHelper.set_dirty()
	last_position = global_position

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.has_method("_enter_fakelight"):
		body.call("_enter_fakelight")

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.has_method("_exit_fakelight"):
		body.call("_exit_fakelight")
