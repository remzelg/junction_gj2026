extends Node2D
class_name HackingGraphNode

@export var number: int = 0
@export var is_target: bool = false
@export var is_start: bool = false
## Marks the target node linked to a door — drawn as a hexagon instead of a
## square, and only hackable while the player is near the door itself.
@export var is_door: bool = false
## Marks the node linked to a rocket-jump mine — drawn as a spiky ball.
## Unlike a door target, this isn't hackable and doesn't count toward
## completion; it's a numbered, proximity-tinted marker mirroring the
## physical mine's location.
@export var is_rocket: bool = false
@export var target_size: float = 48.0
@export var empty_size: float = 18.0
@export var start_radius: float = 9.0

var hacked: bool = false
## Door and rocket nodes only: whether the player is currently near the
## linked physical node. Starts false — a door stays off and unhackable
## until the player is close; a rocket marker just stays untinted.
var proximity_active: bool = false

const COLOR_PLAIN := Color(0.5, 0.52, 0.58)
const COLOR_RED := Color(0.85, 0.18, 0.18)
const COLOR_GREEN := Color(0.22, 0.78, 0.32)
const COLOR_HIGHLIGHT := Color(0.3, 0.85, 1.0, 1.0)

const TARGET_BORDER_WIDTH := 8.0
const EMPTY_BORDER_WIDTH := 5.0
const START_BORDER_WIDTH := 5.0

func _ready() -> void:
	queue_redraw()

## Mirrors the linked physical node's own tint: turns the node on (hackable,
## for a door) while the player is close to it, off otherwise.
func set_proximity_active(value: bool) -> void:
	if proximity_active == value:
		return
	proximity_active = value
	queue_redraw()

func can_hack() -> bool:
	return is_target and not hacked and (not is_door or proximity_active)

func _draw() -> void:
	if is_target:
		var color := _target_color()
		if is_door:
			_draw_hexagon(target_size, TARGET_BORDER_WIDTH, color)
			_draw_number()
		else:
			# Plain (non-door) targets stay unnumbered — only door and
			# rocket-jump nodes need a number to tie them to their linked
			# physical node.
			_draw_square(target_size, TARGET_BORDER_WIDTH, color)
	elif is_rocket:
		# Same highlight mechanic as a door target: plain until the player is
		# near the linked physical mine, then tinted.
		var color := COLOR_HIGHLIGHT if proximity_active else COLOR_PLAIN
		_draw_spiky_ball(target_size, TARGET_BORDER_WIDTH, color)
		_draw_number()
	elif is_start:
		draw_circle(Vector2.ZERO, start_radius, COLOR_PLAIN, false, START_BORDER_WIDTH)
	else:
		_draw_square(empty_size, EMPTY_BORDER_WIDTH, COLOR_PLAIN)

func _draw_number() -> void:
	var font := ThemeDB.fallback_font
	var font_size := 20
	var text := str(number)
	var text_size := font.get_string_size(text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
	draw_string(font, Vector2(-text_size.x / 2.0, text_size.y / 4.0), text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, Color.WHITE)

func _target_color() -> Color:
	if hacked:
		return COLOR_GREEN
	if is_door:
		return COLOR_HIGHLIGHT if proximity_active else COLOR_PLAIN
	return COLOR_RED

# Hollow square drawn as 4 overlapping bars instead of a stroked rect, so the
# corners stay crisp and solid at these line thicknesses.
func _draw_square(size: float, border_width: float, color: Color) -> void:
	var outer := size / 2.0
	var inner := outer - border_width
	draw_rect(Rect2(Vector2(-outer, -outer), Vector2(size, border_width)), color) # top
	draw_rect(Rect2(Vector2(-outer, inner), Vector2(size, border_width)), color) # bottom
	draw_rect(Rect2(Vector2(-outer, -outer), Vector2(border_width, size)), color) # left
	draw_rect(Rect2(Vector2(inner, -outer), Vector2(border_width, size)), color) # right

func _hexagon_points(radius: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	for i in 6:
		var angle := deg_to_rad(60.0 * i - 90.0)
		points.append(Vector2(cos(angle), sin(angle)) * radius)
	return points

func _draw_hexagon(size: float, border_width: float, color: Color) -> void:
	var points := _hexagon_points(size / 2.0)
	points.append(points[0])
	draw_polyline(points, color, border_width, true)

const SPIKE_COUNT := 8

func _spiky_ball_points(inner_radius: float, outer_radius: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	var steps := SPIKE_COUNT * 2
	for i in steps:
		var radius := outer_radius if i % 2 == 0 else inner_radius
		var angle := deg_to_rad(360.0 / steps * i - 90.0)
		points.append(Vector2(cos(angle), sin(angle)) * radius)
	return points

func _draw_spiky_ball(size: float, border_width: float, color: Color) -> void:
	var outer := size / 2.0
	var points := _spiky_ball_points(outer * 0.55, outer)
	points.append(points[0])
	draw_polyline(points, color, border_width, true)

# Distance from center to this node's visual edge, so graph edges can stop
# at the border instead of running through a hollow shape's transparent middle.
func edge_clip_distance() -> float:
	if is_target or is_rocket:
		return target_size / 2.0
	if is_start:
		return start_radius
	return empty_size / 2.0

func hack() -> void:
	if can_hack():
		hacked = true
		queue_redraw()
