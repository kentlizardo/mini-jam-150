extends Control

const INITIAL_ROOM_SIZE := Rect2i(-24, -80, 48, 160)

@export var map_root : Node3D
# References:
#https://jonoshields.com/post/bsp-dungeon
class BSP_Node extends RefCounted:
	var left_child: BSP_Node
	var right_child: BSP_Node
	var bounds: Rect2i
	func _init(bounds: Rect2i) -> void:
		self.bounds = bounds
	func get_leaves() -> Array[BSP_Node]:
		if !(left_child && right_child):
			return [self]
		else:
			return left_child.get_leaves() + right_child.get_leaves()
	func split(count: int) -> void:
		var rng := RandomNumberGenerator.new()
		var split_percent := rng.randf_range(0.3, 0.7)
		var split_horizontal := bounds.size.y >= bounds.size.x
		if split_horizontal:
			var left_height := int(bounds.size.y * split_percent)
			var offset := Vector2i(0, left_height)
			left_child = BSP_Node.new(Rect2i(
				bounds.position,
				Vector2i(bounds.size.x, left_height)
			))
			right_child = BSP_Node.new(Rect2i(
				bounds.position + offset,
				bounds.size - offset
			))
		else:
			var left_width := int(bounds.size.x * split_percent)
			var offset := Vector2i(left_width, 0)
			left_child = BSP_Node.new(Rect2i(
				bounds.position, 
				Vector2i(left_width, bounds.size.y)
				))
			right_child = BSP_Node.new(Rect2i(
				bounds.position + offset,
				bounds.size - offset
			))
		if count > 0:
			left_child.split(count - 1)
			right_child.split(count - 1)

var root_node: BSP_Node

const tile_size := 2

func _ready() -> void:
	root_node = BSP_Node.new(INITIAL_ROOM_SIZE)
	root_node.split(5)
	queue_redraw()
	build()

func _draw() -> void:
	for leaf in root_node.get_leaves():
		var r := Rect2i(
			leaf.bounds.position * tile_size,
			leaf.bounds.size * tile_size
		)
		draw_rect(r, Color.PALE_VIOLET_RED, false)

const WALL := preload("res://scenes/game/map/tile_wall.tscn")
const MIN_PADDING := 2
const MAX_PADDING := 4

func check_padding(pos: Vector2i, padding: Vector4i, leaf: BSP_Node) -> bool:
	return pos.x <= padding.x or pos.y <= padding.y or pos.x > leaf.bounds.size.x - padding.w or pos.y > leaf.bounds.size.y - padding.z

var tiles := {} # tile_pos -> 

func set_tile(tile_pos: Vector2i, scene: PackedScene) -> void:
	if tiles.has(tile_pos):
		tiles[tile_pos].queue_free()
	var tile := scene.instantiate()
	map_root.add_child(tile)
	tile.position.x = tile_pos.x * 2
	tile.position.z = tile_pos.y * 2
	tiles[tile_pos] = tile

func build() -> void:
	await map_root.ready
	var rng := RandomNumberGenerator.new()
	for leaf in root_node.get_leaves():
		var padding := Vector4i(
			rng.randi_range(MIN_PADDING,MAX_PADDING),
			rng.randi_range(MIN_PADDING,MAX_PADDING),
			rng.randi_range(MIN_PADDING,MAX_PADDING),
			rng.randi_range(MIN_PADDING,MAX_PADDING),
		)
		for y in range(leaf.bounds.size.y):
			for x in range(leaf.bounds.size.x):
				var tile_pos := leaf.bounds.position + Vector2i(x,y)
				if check_padding(Vector2i(x, y), padding, leaf):
					set_tile(tile_pos, WALL)

#func _ready() -> void:
	#var bsp := generate_bsp(0, INITIAL_ROOM_SIZE.size.x, 0, INITIAL_ROOM_SIZE.size.y, AxisSplit.values().pick_random())
#
#func generate_bsp(min_x: int, max_x: int, min_y: int, max_y: int, axis: AxisSplit) -> BSPNode:
	#if (max_x - min_x) * (max_y - min_y) < MIN_ROOM_AREA:
		#return null
	#if axis == AxisSplit.HORI:
		#var x_offset := randi_range(min_x, max_x)
		#var n1 := generate_bsp(min_x, x_offset, min_y, max_y, AxisSplit.VERT)
		#var n2 := generate_bsp(x_offset, max_x, min_y, max_y, AxisSplit.VERT)
		#return BSPNode.new(x_offset, AxisSplit.HORI, [n1, n2])
	#else:
		#var y_offset := randi_range(min_y, max_y)
		#var n1 := generate_bsp(min_x, max_x, min_y, y_offset, AxisSplit.HORI)
		#var n2 := generate_bsp(min_x, max_x, y_offset, max_y, AxisSplit.HORI)
		#return BSPNode.new(y_offset, AxisSplit.VERT, [n1, n2])
	#return null
#
#class BSPNode extends RefCounted:
	#var offset := -1
	#var children : Array[BSPNode] = []
	#var axis := AxisSplit.HORI
	#func _init(offset: int, axis: AxisSplit, children: Array[BSPNode]) -> void:
		#self.offset = offset
		#self.axis = axis
		#self.children = children
