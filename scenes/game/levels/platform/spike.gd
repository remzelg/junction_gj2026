extends Area2D
class_name Spike

## Rebar points up (-Y) at rotation 0. Rotate the node in the editor to aim
## the hazard in any direction: 180° for a ceiling trap, ±90° for a wall.

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("lose_level"):
		body.lose_level()
