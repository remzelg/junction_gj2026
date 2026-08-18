extends Node

signal level_lost
signal level_won(level_path : String)
@warning_ignore("unused_signal")
signal level_changed(level_path : String)

## Optional path to the next level if using an open world level system.
@export_file("*.tscn") var next_level_path : String

func _on_lose_button_pressed() -> void:
	level_lost.emit()

func _on_win_button_pressed() -> void:
	level_won.emit(next_level_path)

# Platforming
@onready var collision_polygon_2d: CollisionPolygon2D = $StaticBody2D/CollisionPolygon2D
@onready var polygon2d: Polygon2D = $StaticBody2D/CollisionPolygon2D/Polygon2D

# Hacking-triggered doors: each Door placed in the platform level is paired
# (via its own target_number) with a hacking-graph target node. The graph
# node only turns on (and becomes hackable) while the player is within
# HIGHLIGHT_DISTANCE of its door — otherwise it stays off and can't be
# hacked. Once hacked, the door opens when the player gets within
# DOOR_OPEN_DISTANCE of it. A level can have any number of doors, or none.
#
# A level's rocket-jump mines work the same way as doors for pairing,
# highlighting, and gating: each RocketJump is paired (via its own
# target_number) with a hacking-graph rocket-marker node, which only turns on
# (and becomes triggerable — see HackingGraphNode.can_trigger) while the
# player is physically within HIGHLIGHT_DISTANCE of the mine, same as a door.
# Unlike a door, the mine can't be triggered physically — with the player in
# range, moving the hacking cursor onto the marker node and pressing Space
# there is what actually detonates it (see RocketJump.trigger and
# HackingScene.rocket_triggered), so both proximities are required at once.
const DOOR_OPEN_DISTANCE := 80.0
const HIGHLIGHT_DISTANCE := 150.0

@onready var hacking_scene: HackingScene = get_node_or_null("HackingViewportContainer/SubViewport/HackingScene")
@onready var demo_level: Node2D = get_node_or_null("PlatformViewportContainer/SubViewport/DemoLevel")
@onready var player: Node2D = get_node_or_null("PlatformViewportContainer/SubViewport/DemoLevel/Character")
@onready var complete_marker = get_node_or_null("PlatformViewportContainer/SubViewport/DemoLevel/CompleteMarker")

var _level_completed := false
var _doors: Array = [] # [{node: Door, graph_node: HackingGraphNode, highlighted: bool}, ...]
var _rocket_links: Array = [] # [{node: RocketJump, graph_node: HackingGraphNode, highlighted: bool}, ...]

func _ready() -> void:
	if hacking_scene:
		hacking_scene.all_nodes_triggered.connect(_on_all_nodes_triggered)
		hacking_scene.rocket_triggered.connect(_on_rocket_triggered)
	if player:
		player.lost_level.connect(_on_player_lost_level)
	_collect_doors()
	_collect_rocket_links()

func _collect_doors() -> void:
	if not demo_level or not hacking_scene:
		return
	for child in demo_level.get_children():
		if child is Door:
			var graph_node := hacking_scene.get_target_node(child.target_number)
			if graph_node:
				graph_node.is_door = true
				graph_node.queue_redraw()
				_doors.append({"node": child, "graph_node": graph_node, "highlighted": false})

func _collect_rocket_links() -> void:
	if not demo_level or not hacking_scene:
		return
	for child in demo_level.get_children():
		if child is RocketJump:
			var graph_node := hacking_scene.get_rocket_node(child.target_number)
			if graph_node:
				_rocket_links.append({"node": child, "graph_node": graph_node, "highlighted": false})

func _on_player_lost_level() -> void:
	level_lost.emit()

func _on_all_nodes_triggered() -> void:
	if complete_marker:
		complete_marker.show_marker()

func _on_rocket_triggered(number: int) -> void:
	for rocket_link in _rocket_links:
		var node: RocketJump = rocket_link["node"]
		if node.target_number == number:
			node.trigger()
			return

func _process(_delta: float) -> void:
	if player:
		for door_link in _doors:
			_update_door_link(door_link)
		for rocket_link in _rocket_links:
			_update_proximity_highlight(rocket_link)
	if not _level_completed and complete_marker and complete_marker.visible and player:
		if player.global_position.distance_to(complete_marker.global_position) <= complete_marker.RADIUS:
			_level_completed = true
			level_won.emit(next_level_path)

func _update_door_link(link: Dictionary) -> void:
	_update_proximity_highlight(link)
	var door: Node2D = link["node"]
	var graph_node: HackingGraphNode = link["graph_node"]
	if graph_node.hacked and player.global_position.distance_to(door.global_position) <= DOOR_OPEN_DISTANCE:
		door.open()

func _update_proximity_highlight(link: Dictionary) -> void:
	var physical_node: Node2D = link["node"]
	var graph_node: HackingGraphNode = link["graph_node"]
	var near := player.global_position.distance_to(physical_node.global_position) <= HIGHLIGHT_DISTANCE
	if near != link["highlighted"]:
		link["highlighted"] = near
		if physical_node.has_method("set_highlighted"):
			physical_node.set_highlighted(near)
		graph_node.set_proximity_active(near)
