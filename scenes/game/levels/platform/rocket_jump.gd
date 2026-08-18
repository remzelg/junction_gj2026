extends Area2D
class_name RocketJump

## A reusable mine. It can't be armed physically — level.gd calls trigger()
## when the player hacks this mine's marker node in the hacking minigame
## (see HackingScene.rocket_triggered). After a short fuse it detonates,
## flinging the player radially away from its position (only if they're
## within EXPLOSION_RADIUS of the mine when it goes off), then goes inert for
## a few seconds before resetting so it can be triggered again.

## Which hacking-graph rocket-marker number this mine is paired with —
## mirrors Door.target_number, so a level can place several mines, each tied
## to its own graph node.
@export var target_number: int = 1

const FUSE_DURATION := 0.5
const RESPAWN_DELAY := 2.5
const LAUNCH_STRENGTH := 900.0
## Distance at detonation time within which a nearby body gets launched.
## Separate from the (much larger) CollisionShape2D trigger radius — a
## trigger can come from the hacking minigame while the player is far away,
## but they have to actually be near the mine when the fuse runs out to
## catch the blast.
const EXPLOSION_RADIUS := 100.0

const BODY_RADIUS := 20.0
const SPIKE_COUNT := 8
const SPIKE_LENGTH := 10.0

const FILL_COLOR := Color(0.18, 0.18, 0.2, 1)
const HIGHLIGHT_COLOR := Color(0.3, 0.85, 1.0, 1.0)
const ARMED_COLOR := Color(1.0, 0.5, 0.2)

enum State { READY, ARMED, RESPAWNING }

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

var _state: State = State.READY
var _highlighted := false
## Whichever body is currently overlapping the trigger CollisionShape2D, kept
## live via body_entered/exited — not a snapshot, since trigger() now fires
## remotely (from the hacking minigame) rather than from this body's own
## input, so there's no single "who pressed the button" to freeze at arm
## time. Explosion checks this body's live position against EXPLOSION_RADIUS.
var _body_in_range: Node2D = null

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

## Tints the mine when the player is close by, without changing its shape —
## same mechanic as Door.set_highlighted.
func set_highlighted(value: bool) -> void:
	if _highlighted == value:
		return
	_highlighted = value
	queue_redraw()

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("apply_rocket_launch"):
		_body_in_range = body

func _on_body_exited(body: Node2D) -> void:
	if body == _body_in_range:
		_body_in_range = null

## Called by level.gd when the player hacks this mine's marker node in the
## hacking minigame. A no-op unless the mine is currently READY, so spamming
## the marker while ARMED/RESPAWNING doesn't restart or stack the fuse.
func trigger() -> void:
	if _state == State.READY:
		_arm()

func _arm() -> void:
	_state = State.ARMED
	queue_redraw()
	await get_tree().create_timer(FUSE_DURATION).timeout
	_explode()

func _explode() -> void:
	audio_player.stream = load("res://assets/sound/bomb.wav")
	audio_player.play()
	if is_instance_valid(_body_in_range):
		var away := _body_in_range.global_position - global_position
		if away.length() <= EXPLOSION_RADIUS:
			var direction := away.normalized() if away.length() > 0.001 else Vector2.UP
			_body_in_range.apply_rocket_launch(direction * LAUNCH_STRENGTH)
	visible = false
	collision_shape.set_deferred("disabled", true)
	_state = State.RESPAWNING
	await get_tree().create_timer(RESPAWN_DELAY).timeout
	_respawn()

func _respawn() -> void:
	visible = true
	collision_shape.set_deferred("disabled", false)
	_state = State.READY
	queue_redraw()

func _current_color() -> Color:
	if _state == State.ARMED:
		return ARMED_COLOR
	return HIGHLIGHT_COLOR if _highlighted else FILL_COLOR

func _draw() -> void:
	var points := PackedVector2Array()
	var steps := SPIKE_COUNT * 2
	for i in steps:
		var radius := BODY_RADIUS + SPIKE_LENGTH if i % 2 == 0 else BODY_RADIUS
		var angle := deg_to_rad(360.0 / steps * i - 90.0)
		points.append(Vector2(cos(angle), sin(angle)) * radius)
	draw_colored_polygon(points, _current_color())
	_draw_number()

func _draw_number() -> void:
	var font := ThemeDB.fallback_font
	var font_size := 20
	var text := str(target_number)
	var text_size := font.get_string_size(text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
	draw_string(font, Vector2(-text_size.x / 2.0, text_size.y / 4.0), text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, Color.WHITE)
