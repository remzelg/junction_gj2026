extends Node2D
class_name HackingScene

signal node_triggered(number: int)
signal all_nodes_triggered

## Generic graph engine: layout data (positions, connections, targets) is
## supplied by a per-level subclass (see hacking_1.gd / hacking_2.gd /
## hacking_3.gd) instead of being hardcoded here, so each level can use its
## own — possibly asymmetric — formation of nodes instead of a fixed grid.

## Local-space position of each graph node, indexed 0..N-1.
var node_positions: Array[Vector2] = []
## Undirected connections between node_positions indices. Only these pairs
## are drawn as edges and navigable by the hacking indicator.
var edges: Array[Vector2i] = []
## node_positions index -> displayed number, for red/target nodes.
var target_numbers: Dictionary = {}
## node_positions index where the hacking indicator spawns.
var start_index: int = 0
## node_positions index -> displayed number, for rocket-jump marker nodes.
## Mirrors target_numbers, but these aren't hackable and don't count toward
## completion — each is a numbered, proximity-tinted marker for a matching
## RocketJump mine (by its own target_number) in the platform level.
var rocket_numbers: Dictionary = {}

@onready var status_label: Label = $UI/StatusLabel
@onready var graph_nodes_container: Node2D = $HackingLevel/GraphNodes

var grid_nodes: Array = [] # flat array of HackingGraphNode, index matches node_positions
var target_count := 0
var _adjacency: Dictionary = {} # node index -> Array[int] of connected neighbor indices

func _ready() -> void:
	_build_graph()
	update_status(0)
	queue_redraw()

func _build_graph() -> void:
	for i in node_positions.size():
		var node := HackingGraphNode.new()
		node.position = node_positions[i]
		if target_numbers.has(i):
			node.is_target = true
			node.number = target_numbers[i]
			target_count += 1
		elif rocket_numbers.has(i):
			node.is_rocket = true
			node.number = rocket_numbers[i]
		elif i == start_index:
			node.is_start = true
		graph_nodes_container.add_child(node)
		grid_nodes.append(node)
		_adjacency[i] = []
	for edge in edges:
		_adjacency[edge.x].append(edge.y)
		_adjacency[edge.y].append(edge.x)

func _draw() -> void:
	for edge in edges:
		_draw_edge(edge.x, edge.y)

const EDGE_COLOR := Color(0.42, 0.45, 0.52)
const EDGE_WIDTH := 3.0

func _draw_edge(a_index: int, b_index: int) -> void:
	if grid_nodes.is_empty():
		return
	var node_a: HackingGraphNode = grid_nodes[a_index]
	var node_b: HackingGraphNode = grid_nodes[b_index]
	var a := to_local(node_a.global_position)
	var b := to_local(node_b.global_position)
	var dir := (b - a).normalized()
	# All nodes are hollow shapes, so stop the line at each one's border
	# instead of running it through the transparent center.
	a += dir * node_a.edge_clip_distance()
	b -= dir * node_b.edge_clip_distance()
	draw_line(a, b, EDGE_COLOR, EDGE_WIDTH)

func get_target_node(number: int) -> HackingGraphNode:
	for node in grid_nodes:
		if node.is_target and node.number == number:
			return node
	return null

func get_rocket_node(number: int) -> HackingGraphNode:
	for node in grid_nodes:
		if node.is_rocket and node.number == number:
			return node
	return null

## Bounding box of every node's position — used by the hacking indicator to
## size its camera's pan limits to whatever this level's layout actually
## covers, instead of a one-size-fits-all constant.
func get_graph_bounds() -> Rect2:
	if node_positions.is_empty():
		return Rect2()
	var min_x := node_positions[0].x
	var min_y := node_positions[0].y
	var max_x := min_x
	var max_y := min_y
	for pos in node_positions:
		min_x = min(min_x, pos.x)
		min_y = min(min_y, pos.y)
		max_x = max(max_x, pos.x)
		max_y = max(max_y, pos.y)
	return Rect2(Vector2(min_x, min_y), Vector2(max_x - min_x, max_y - min_y))

# Grid query API used by the hacking indicator (the "player") to navigate.
# Picks whichever edge-connected neighbor is most closely aligned with the
# pressed compass direction, so movement works over any graph shape — not
# just an axis-aligned row/col lattice.
const DIRECTION_ALIGNMENT_THRESHOLD := 0.4

func neighbor_index(index: int, direction: Vector2) -> int:
	if direction == Vector2.ZERO:
		return -1
	var best_index := -1
	var best_dot := DIRECTION_ALIGNMENT_THRESHOLD
	for neighbor in _adjacency.get(index, []):
		var delta: Vector2 = grid_nodes[neighbor].position - grid_nodes[index].position
		var dot := delta.normalized().dot(direction)
		if dot > best_dot:
			best_dot = dot
			best_index = neighbor
	return best_index

func direction_valid(index: int, direction: Vector2) -> bool:
	return direction != Vector2.ZERO and neighbor_index(index, direction) != -1

func update_status(hacked_count: int) -> void:
	if hacked_count >= target_count:
		status_label.text = "All nodes hacked! (%d/%d)" % [hacked_count, target_count]
	else:
		status_label.text = "Hacked %d/%d — move onto a red node and press Space" % [hacked_count, target_count]
