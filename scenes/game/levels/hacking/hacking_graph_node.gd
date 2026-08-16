extends Node2D
class_name HackingGraphNode

@export var number: int = 0
@export var is_target: bool = false
@export var radius: float = 22.0

var hacked: bool = false

const COLOR_PLAIN := Color(0.5, 0.52, 0.58)
const COLOR_RED := Color(0.85, 0.18, 0.18)
const COLOR_GREEN := Color(0.22, 0.78, 0.32)
const COLOR_OUTLINE := Color(0, 0, 0, 0.6)

func _draw() -> void:
	var color := COLOR_PLAIN
	if is_target:
		color = COLOR_GREEN if hacked else COLOR_RED
	draw_circle(Vector2.ZERO, radius, color)
	draw_circle(Vector2.ZERO, radius, COLOR_OUTLINE, false, 2.0)
	if is_target:
		var font := ThemeDB.fallback_font
		var font_size := 20
		var text := str(number)
		var text_size := font.get_string_size(text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
		draw_string(font, Vector2(-text_size.x / 2.0, text_size.y / 4.0), text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, Color.WHITE)

func hack() -> void:
	if is_target and not hacked:
		hacked = true
		queue_redraw()
