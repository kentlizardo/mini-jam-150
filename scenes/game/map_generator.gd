extends Control

const INITIAL_ROOM_SIZE := Rect2i(0, 0, 24, 80)
const MIN_ROOM_AREA = 20
enum AxisSplit {
	HORI,
	VERT,
}

func _ready() -> void:
	var bsp := generate_bsp(0, INITIAL_ROOM_SIZE.size.x, 0, INITIAL_ROOM_SIZE.size.y, AxisSplit.values().pick_random())

func generate_bsp(min_x: int, max_x: int, min_y: int, max_y: int, axis: AxisSplit) -> BSPNode:
	if (max_x - min_x) * (max_y - min_y) < MIN_ROOM_AREA:
		return null
	if axis == AxisSplit.HORI:
		var x_offset := randi_range(min_x, max_x)
		var n1 := generate_bsp(min_x, x_offset, min_y, max_y, AxisSplit.VERT)
		var n2 := generate_bsp(x_offset, max_x, min_y, max_y, AxisSplit.VERT)
		return BSPNode.new(x_offset, AxisSplit.HORI, [n1, n2])
	else:
		var y_offset := randi_range(min_y, max_y)
		var n1 := generate_bsp(min_x, max_x, min_y, y_offset, AxisSplit.HORI)
		var n2 := generate_bsp(min_x, max_x, y_offset, max_y, AxisSplit.HORI)
		return BSPNode.new(y_offset, AxisSplit.VERT, [n1, n2])
	return null

class BSPNode extends RefCounted:
	var offset := -1
	var children : Array[BSPNode] = []
	var axis := AxisSplit.HORI
	func _init(offset: int, axis: AxisSplit, children: Array[BSPNode]) -> void:
		self.offset = offset
		self.axis = axis
		self.children = children
