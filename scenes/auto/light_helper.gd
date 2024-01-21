extends Node

var terrain_shader := load("res://res/terrain_shader.tres") as ShaderMaterial

var dirty := false
var lights : Array[FakeLight] = []

func add_light(light: FakeLight) -> void:
	lights.push_back(light)
	dirty = true

func remove_light(light: FakeLight) -> bool:
	var i := lights.find(light)
	if i != -1:
		lights.remove_at(i)
		dirty = true
		return true
	return false

func set_dirty() -> void:
	dirty = true

const SPHERES = "spheres"
const SPHERE_COUNT = "sphere_count"
func _process(delta: float) -> void:
	if dirty:
		terrain_shader.set_shader_parameter(SPHERE_COUNT, lights.size())
		var vecs := PackedVector3Array(lights.map(convert_light))
		terrain_shader.set_shader_parameter(SPHERES, vecs)
		dirty = false

func convert_light(light: FakeLight) -> Vector3:
	return Vector3(light.global_position.x, light.global_position.z, light.radius)

