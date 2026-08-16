# Attach this script to your AudioStreamPlayer, AudioStreamPlayer2D, or AudioStreamPlayer3D
extends AudioStreamPlayer2D

func _ready() -> void:
	play()
	finished.connect(_on_finished)

func _on_finished() -> void:
	play()
