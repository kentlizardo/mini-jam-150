extends Control

const INITIAL_ROOM_SIZE := Rect2i(-24, -80, 48, 160)
const MONSTERS_PER_ROOM := Vector2i(1, 2)
var MONSTER_TABLE := [
	load("res://scenes/game/enemies/goblin.tscn"),
	load("res://scenes/game/enemies/armor.tscn"),
]

const tile_size := 1

@export var map_root : Node3D

var root_node: BSP_Node
var paths: Array[Dictionary] = []
var tiles := {} # tile_pos -> Node3D
var player_marker := Vector2.ZERO

func _ready() -> void:
	root_node = BSP_Node.new(INITIAL_ROOM_SIZE)
	root_node.split(4, paths)
	queue_redraw()
	build()

func _draw() -> void:
	for leaf in root_node.get_leaves():
		var r := Rect2i(
			leaf.bounds.position * tile_size,
			leaf.bounds.size * tile_size
		)
		r.position += Vector2i(size / 2)
		draw_rect(r, Color.PALE_VIOLET_RED, false)
	var p := player_marker * tile_size + Vector2(size / 2)
	draw_circle(p, tile_size * 2, Color.BLUE)

const WALL := preload("res://scenes/game/map/tile_wall.tscn")
const FLOOR := preload("res://scenes/game/map/tile_floor.tscn")
const MIN_PADDING := 2
const MAX_PADDING := 3

func check_padding(pos: Vector2i, padding: Vector4i, leaf: BSP_Node) -> bool:
	return pos.x <= padding.x or pos.y <= padding.y or pos.x > leaf.bounds.size.x - padding.w or pos.y > leaf.bounds.size.y - padding.z

func set_tile(tile_pos: Vector2i, scene: PackedScene) -> void:
	if tiles.has(tile_pos):
		tiles[tile_pos].queue_free()
	var tile := scene.instantiate()
	if tile is TileFloor:
		tile.entered.connect(set_player_floor.bind(tile_pos))
	map_root.add_child(tile)
	tile.position.x = tile_pos.x * 2
	tile.position.z = tile_pos.y * 2
	tiles[tile_pos] = tile

func add_entity(tile_pos: Vector2i, scene: PackedScene) -> void:
	var ent := scene.instantiate() as Node3D
	map_root.add_child(ent)
	ent.position.x = tile_pos.x * 2
	ent.position.z = tile_pos.y * 2
	ent.position.y = 1

func set_player_floor(pos: Vector2i) -> void:
	player_marker = pos
	queue_redraw()

func build() -> void:
	var rng := RandomNumberGenerator.new()
	for leaf in root_node.get_leaves():
		var padding := Vector4i(
			rng.randi_range(MIN_PADDING,MAX_PADDING),
			rng.randi_range(MIN_PADDING,MAX_PADDING),
			rng.randi_range(MIN_PADDING,MAX_PADDING),
			rng.randi_range(MIN_PADDING,MAX_PADDING),
		)
		var unoccupied: Array[Vector2i] = []
		for y in range(leaf.bounds.size.y):
			for x in range(leaf.bounds.size.x):
				var tile_pos := leaf.bounds.position + Vector2i(x,y)
				if check_padding(Vector2i(x, y), padding, leaf):
					set_tile(tile_pos, WALL)
				else:
					set_tile(tile_pos, FLOOR)
					unoccupied.append(tile_pos)
		for i in range(0, randi_range(MONSTERS_PER_ROOM.x, MONSTERS_PER_ROOM.y)):
			if unoccupied.size() > 0:
				var space := unoccupied.pick_random() as Vector2i
				add_entity(space, MONSTER_TABLE.pick_random())
				unoccupied.remove_at(unoccupied.find(space))
	for path: Dictionary in paths:
		if path["left"].y == path["right"].y:
			for i in range(path["right"].x - path["left"].x):
				var tile_pos := Vector2i(path["left"].x + i, path["left"].y)
				set_tile(tile_pos, FLOOR)
		else:
			for i in range(path["right"].y - path["left"].y):
				var tile_pos := Vector2i(path["left"].x, path["left"].y + i)
				set_tile(tile_pos, FLOOR)

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
	func split(count: int, paths: Array[Dictionary]) -> void:
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
		paths.append({
			"left": left_child.bounds.get_center(),
			"right": right_child.bounds.get_center(),
		})
		if count > 0:
			left_child.split(count - 1, paths)
			right_child.split(count - 1, paths)
