extends Node2D

@onready var collision_shape: CollisionShape2D = $StaticBody2D/CollisionShape2D

func open() -> void:
	visible = false
	collision_shape.set_deferred("disabled", true)
