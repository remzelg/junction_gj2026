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

# Hacking-triggered door: once TARGET_NODE_NUMBER is hacked, the door opens
# when the player gets within DOOR_OPEN_DISTANCE of it. Only wired up when
# both a hacking scene and a door are present (e.g. the level_1 layout).
const TARGET_NODE_NUMBER := 1
const DOOR_OPEN_DISTANCE := 80.0

@onready var hacking_scene: HackingScene = get_node_or_null("HackingViewportContainer/SubViewport/HackingScene")
@onready var door = get_node_or_null("PlatformViewportContainer/SubViewport/DemoLevel/Door")
@onready var player: Node2D = get_node_or_null("PlatformViewportContainer/SubViewport/DemoLevel/Character")
@onready var complete_marker = get_node_or_null("PlatformViewportContainer/SubViewport/DemoLevel/CompleteMarker")

var _target_node_hacked := false
var _level_completed := false

func _ready() -> void:
	if hacking_scene:
		hacking_scene.node_triggered.connect(_on_node_triggered)
		hacking_scene.all_nodes_triggered.connect(_on_all_nodes_triggered)

func _on_node_triggered(number: int) -> void:
	if number == TARGET_NODE_NUMBER:
		_target_node_hacked = true

func _on_all_nodes_triggered() -> void:
	if complete_marker:
		complete_marker.show_marker()

func _process(_delta: float) -> void:
	if _target_node_hacked and door and door.visible and player:
		if player.global_position.distance_to(door.global_position) <= DOOR_OPEN_DISTANCE:
			door.open()
	if not _level_completed and complete_marker and complete_marker.visible and player:
		if player.global_position.distance_to(complete_marker.global_position) <= complete_marker.RADIUS:
			_level_completed = true
			level_won.emit(next_level_path)
