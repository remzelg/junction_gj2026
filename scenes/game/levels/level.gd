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

func open_tutorials() -> void:
	%TutorialManager.open_tutorials()

func _ready() -> void:
	open_tutorials()
	# Sets the collision shape to white so its visible
	#polygon2d.polygon = collision_polygon_2d.polygon

func _on_tutorial_button_pressed() -> void:
	open_tutorials()

# Platforming
@onready var collision_polygon_2d: CollisionPolygon2D = $StaticBody2D/CollisionPolygon2D
@onready var polygon2d: Polygon2D = $StaticBody2D/CollisionPolygon2D/Polygon2D
