extends Node

signal staging_finished(stage: Node)

var starting_stage: PackedScene

var _stage: Node = null
var stage: Node:
	get = get_current_stage
func get_current_stage() -> Node:
	return _stage

var is_staging: bool = false

func _ready() -> void:
	if starting_stage:
		stage_scene(starting_stage)

func stage_scene(scene: PackedScene) -> void:
	stage_orphan(scene.instantiate())
func stage_orphan(node: Node) -> void:
	_stage_orphan.call_deferred(node)
func _stage_orphan(node : Node) -> void:
	if is_staging:
		push_error("Staging a new NodeTree while another is being staged.")
	try_unstage()
	add_child.call_deferred(node)

func unstage() -> void:
	assert(is_instance_valid(stage), "Error: Should not be unstaging an invalid node")
	stage.queue_free()
	stage = null
func try_unstage() -> bool:
	if is_instance_valid(stage):
		unstage()
		return true
	return false
