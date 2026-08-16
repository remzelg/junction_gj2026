extends Sprite2D

func _process(delta: float) -> void:
	if randf() > 0.5:
		if frame < 165:
			frame = frame + 1
		else:
			frame = 0
