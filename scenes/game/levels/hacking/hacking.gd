extends Node2D
class_name HackingScene

signal node_triggered(number: int)
signal all_nodes_triggered

const COLS := 5
const ROWS := 3
const COL_X := [160.0, 400.0, 640.0, 880.0, 1120.0]
const ROW_Y := [180.0, 360.0, 540.0]

# grid index (row * COLS + col) -> displayed number for red/target nodes
const TARGET_NUMBERS := {
	1: 1, # row 0, col 1
	3: 2, # row 0, col 3
	6: 3, # row 1, col 1
	8: 4, # row 1, col 3
	12: 5, # row 2, col 2
}

@onready var status_label: Label = $UI/StatusLabel
@onready var graph_nodes_container: Node2D = $HackingLevel/GraphNodes

var grid_nodes: Array = [] # flat array of HackingGraphNode, index = row * COLS + col
var target_count := 0

func _ready() -> void:
	_build_grid()
	update_status(0)
	queue_redraw()

func _build_grid() -> void:
	for row in ROWS:
		for col in COLS:
			var index := row * COLS + col
			var node := HackingGraphNode.new()
			node.position = Vector2(COL_X[col], ROW_Y[row])
			if TARGET_NUMBERS.has(index):
				node.is_target = true
				node.number = TARGET_NUMBERS[index]
				target_count += 1
			graph_nodes_container.add_child(node)
			grid_nodes.append(node)

func _draw() -> void:
	for row in ROWS:
		for col in COLS:
			var index := row * COLS + col
			if col + 1 < COLS:
				_draw_edge(index, index + 1)
			if row + 1 < ROWS:
				_draw_edge(index, index + COLS)

func _draw_edge(a_index: int, b_index: int) -> void:
	if grid_nodes.is_empty():
		return
	var a := to_local(grid_nodes[a_index].global_position)
	var b := to_local(grid_nodes[b_index].global_position)
	draw_line(a, b, Color(0.4, 0.42, 0.48), 3.0)

# Grid query API used by the hacking indicator (the "player") to navigate.
func neighbor_index(index: int, direction: Vector2) -> int:
	var row := index / COLS
	var col := index % COLS
	if direction == Vector2.UP:
		row -= 1
	elif direction == Vector2.DOWN:
		row += 1
	elif direction == Vector2.LEFT:
		col -= 1
	elif direction == Vector2.RIGHT:
		col += 1
	if row < 0 or row >= ROWS or col < 0 or col >= COLS:
		return -1
	return row * COLS + col

func direction_valid(index: int, direction: Vector2) -> bool:
	return direction != Vector2.ZERO and neighbor_index(index, direction) != -1

func update_status(hacked_count: int) -> void:
	if hacked_count >= target_count:
		status_label.text = "All nodes hacked! (%d/%d)" % [hacked_count, target_count]
	else:
		status_label.text = "Hacked %d/%d — move onto a red node and press Space" % [hacked_count, target_count]
