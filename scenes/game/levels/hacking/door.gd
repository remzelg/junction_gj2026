extends Node2D
class_name Door

## Which hacking-graph target number must be hacked to open this door. Lets
## a level place more than one door, each paired with its own graph target.
@export var target_number: int = 1

const FILL_COLOR := Color(0.28778407, 0.28778407, 0.28778407, 1)
const HIGHLIGHT_COLOR := Color(0.3, 0.85, 1.0, 1.0)
const OPEN_DROP := 200.0
const OPEN_DURATION := 0.6

@onready var collision_shape: CollisionShape2D = $StaticBody2D/CollisionShape2D
@onready var color_rect: ColorRect = $ColorRect
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var number_label: Label = $NumberLabel

var _opened := false

func _ready() -> void:
	number_label.text = str(target_number)

## Tints the door when the player is close by, without changing its shape.
func set_highlighted(value: bool) -> void:
	color_rect.color = HIGHLIGHT_COLOR if value else FILL_COLOR

func open() -> void:
	if _opened:
		return
	_opened = true
	collision_shape.set_deferred("disabled", true)
	audio_player.stream = load("res://assets/sound/scifi_door.wav")
	audio_player.play()
	var tween := create_tween()
	tween.tween_property(self, "position:y", position.y + OPEN_DROP, OPEN_DURATION)
