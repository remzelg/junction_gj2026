extends Node2D

const RADIUS := 40.0
const CIRCLE_COLOR := Color(0.22, 0.78, 0.32, 0.85)

func _ready() -> void:
	visible = false

func _draw() -> void:
	draw_circle(Vector2.ZERO, RADIUS, CIRCLE_COLOR)

func show_marker() -> void:
	visible = true
	queue_redraw()
