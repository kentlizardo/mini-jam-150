extends Control

const INITIAL_ROOM_SIZE := Rect2i(-12, -40, 24, 80)
const MONSTERS_PER_ROOM := Vector2i(2, 4)
var MONSTER_TABLE := [
	load("res://scenes/game/enemies/goblin.tscn"),
	#load("res://scenes/game/enemies/armor.tscn"),
	#load("res://scenes/game/enemies/lighteater.tscn"),
]
var LANTERN := load("res://scenes/game/enemies/lantern.tscn")

const tile_size := 1

@export var map_root : Node3D

var root_node: BSP_Node
var paths: Array[Dictionary] = []
var tiles := {} # tile_pos -> Node3D
var tile_entities := {} # tile_pos -> Node3D
var floor_pos_to_room := {} # floor_pos -> leaf BSP_Node
var player_marker := Vector2i.ZERO

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
		if leaf.entered:
			draw_rect(r, Color.TEAL, true)
		draw_rect(r, Color.PALE_VIOLET_RED, false)
	var p := Vector2(player_marker) * tile_size + Vector2(size / 2)
	draw_circle(p, tile_size * 2, Color.BLUE)

const WALL := preload("res://scenes/game/map/tile_wall.tscn")
const FLOOR := preload("res://scenes/game/map/tile_floor.tscn")
const MIN_PADDING := 1
const MAX_PADDING := 2

func check_padding(pos: Vector2i, padding: Vector4i, leaf: BSP_Node) -> bool:
	return pos.x <= padding.x or pos.y <= padding.y or pos.x > leaf.bounds.size.x - padding.w - 1 or pos.y > leaf.bounds.size.y - padding.z - 1

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
	tile_entities[tile_pos] = ent
	map_root.add_child(ent)
	ent.position.x = tile_pos.x * 2
	ent.position.z = tile_pos.y * 2
	ent.position.y = 1

func set_player_floor(pos: Vector2i) -> void:
	player_marker = pos
	if floor_pos_to_room.has(pos):
		floor_pos_to_room[pos].entered = true
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
		leaf.data["unoccupied"] = [] as Array[Vector2i]
		for y in range(leaf.bounds.size.y):
			for x in range(leaf.bounds.size.x):
				var tile_pos := leaf.bounds.position + Vector2i(x,y)
				if check_padding(Vector2i(x, y), padding, leaf):
					set_tile(tile_pos, WALL)
				else:
					set_tile(tile_pos, FLOOR)
					floor_pos_to_room[tile_pos] = leaf
					leaf.data["unoccupied"].append(tile_pos)
		for i in range(0, randi_range(MONSTERS_PER_ROOM.x, MONSTERS_PER_ROOM.y)):
			if leaf.data["unoccupied"].size() > 0:
				var space := leaf.data["unoccupied"].pick_random() as Vector2i
				add_entity(space, MONSTER_TABLE.pick_random())
				leaf.data["unoccupied"].remove_at(leaf.data["unoccupied"].find(space))
		for i in range(randi_range(0, 4)):
			if leaf.data["unoccupied"].size() > 0:
				var space := leaf.data["unoccupied"].pick_random() as Vector2i
				add_entity(space, LANTERN)
				leaf.data["unoccupied"].remove_at(leaf.data["unoccupied"].find(space))
	for path: Dictionary in paths:
		if path["left"].y == path["right"].y:
			for i in range(path["right"].x - path["left"].x):
				var tile_pos := Vector2i(path["left"].x + i, path["left"].y)
				set_tile(tile_pos, FLOOR)
		else:
			for i in range(path["right"].y - path["left"].y):
				var tile_pos := Vector2i(path["left"].x, path["left"].y + i)
				set_tile(tile_pos, FLOOR)
	var ladder_spawns := []
	var player_spawns := []
	for y in range(20):
		for x in range(root_node.bounds.size.x):
			var tile_pos := Vector2i(root_node.bounds.position.x + x, root_node.bounds.position.y + y)
			if tiles.has(tile_pos):
				if tiles[tile_pos] is TileFloor and !tile_entities.keys().has(tile_pos):
					ladder_spawns.push_back(tile_pos)
	for y in range(20):
		for x in range(root_node.bounds.size.x):
			var tile_pos := Vector2i(root_node.bounds.position.x + x, root_node.bounds.position.y + root_node.bounds.size.y - y)
			if tiles.has(tile_pos):
				if tiles[tile_pos] is TileFloor and !tile_entities.keys().has(tile_pos):
					player_spawns.push_back(tile_pos)
	await get_tree().process_frame
	for leaf in root_node.get_leaves():
		leaf.entered = false
	var p_spawn := player_spawns.pick_random() as Vector2i
	var player := Player.current_player
	player.position.x = p_spawn.x * 2
	player.position.z = p_spawn.y * 2
	player.position.y = 1
	var l_spawn := ladder_spawns.pick_random() as Vector2i
	add_entity(l_spawn, load("res://scenes/game/enemies/ladder.tscn"))
	for i: Node3D in tile_entities.values():
		if i.global_position.distance_to(player.global_position) <= 20:
			i.queue_free()

# References:
#https://jonoshields.com/post/bsp-dungeon
class BSP_Node extends RefCounted:
	var left_child: BSP_Node
	var right_child: BSP_Node
	var bounds: Rect2i
	
	var data : Dictionary = {}
	var entered := false
	func _init(bounds: Rect2i) -> void:
		self.bounds = bounds
	func get_leaves() -> Array[BSP_Node]:
		if !(left_child && right_child):
			return [self]
		else:
			return left_child.get_leaves() + right_child.get_leaves()
	func split(count: int, paths: Array[Dictionary]) -> void:
		var rng := RandomNumberGenerator.new()
		var split_percent := rng.randf_range(0.4, 0.6)
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
