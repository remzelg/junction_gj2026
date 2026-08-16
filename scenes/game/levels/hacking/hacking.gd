extends Node2D

const COLS := 5
const ROWS := 3
const COL_X := [160.0, 400.0, 640.0, 880.0, 1120.0]
const ROW_Y := [180.0, 360.0, 540.0]
const SPEED := 300.0
const HACK_RADIUS := 26.0

# grid index (row * COLS + col) -> displayed number for red/target nodes
const TARGET_NUMBERS := {
	1: 1, # row 0, col 1
	3: 2, # row 0, col 3
	6: 3, # row 1, col 1
	8: 4, # row 1, col 3
	12: 5, # row 2, col 2
}

const START_INDEX := 5 # row 1, col 0

@onready var status_label: Label = $StatusLabel
@onready var indicator: Sprite2D = $HackingLevel/HackingIndicator
@onready var graph_nodes_container: Node2D = $HackingLevel/GraphNodes

var grid_nodes: Array = [] # flat array of HackingGraphNode, index = row * COLS + col
var current_index := START_INDEX
var target_index := START_INDEX
var current_direction := Vector2.ZERO
var queued_direction := Vector2.ZERO

var target_count := 0
var hacked_count := 0

func _ready() -> void:
	_build_grid()
	indicator.position = grid_nodes[current_index].position
	_update_status()
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

func _process(delta: float) -> void:
	_read_input()
	_move_indicator(delta)
	if Input.is_action_just_pressed("ui_accept"):
		_try_hack()

func _read_input() -> void:
	if Input.is_action_just_pressed("move_up"):
		queued_direction = Vector2.UP
	elif Input.is_action_just_pressed("move_down"):
		queued_direction = Vector2.DOWN
	elif Input.is_action_just_pressed("move_left"):
		queued_direction = Vector2.LEFT
	elif Input.is_action_just_pressed("move_right"):
		queued_direction = Vector2.RIGHT

func _move_indicator(delta: float) -> void:
	if target_index == current_index:
		_try_leave_node()
		return

	var target_position: Vector2 = grid_nodes[target_index].position
	var offset := target_position - indicator.position
	var step := SPEED * delta
	if offset.length() <= step:
		indicator.position = target_position
		current_index = target_index
		_try_leave_node()
	else:
		indicator.position += offset.normalized() * step

# Called on arrival at a node (and every frame while idle) to pick the next
# direction: prefer the last direction the player pressed, otherwise keep
# going straight, otherwise stop.
func _try_leave_node() -> void:
	if _direction_valid(current_index, queued_direction):
		current_direction = queued_direction
	elif not _direction_valid(current_index, current_direction):
		current_direction = Vector2.ZERO

	if current_direction != Vector2.ZERO:
		target_index = _neighbor_index(current_index, current_direction)
	else:
		target_index = current_index

func _direction_valid(index: int, direction: Vector2) -> bool:
	return direction != Vector2.ZERO and _neighbor_index(index, direction) != -1

func _neighbor_index(index: int, direction: Vector2) -> int:
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

func _try_hack() -> void:
	for node in grid_nodes:
		if node.is_target and not node.hacked and node.position.distance_to(indicator.position) <= HACK_RADIUS:
			node.hack()
			hacked_count += 1
			_update_status()
			return

func _update_status() -> void:
	if hacked_count >= target_count:
		status_label.text = "All nodes hacked! (%d/%d)" % [hacked_count, target_count]
	else:
		status_label.text = "Hacked %d/%d — move onto a red node and press Space" % [hacked_count, target_count]
