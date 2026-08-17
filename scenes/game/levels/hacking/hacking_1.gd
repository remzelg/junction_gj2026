extends HackingScene

## Level 1's original 5x3 grid layout, preserved as-is.
func _init() -> void:
	node_positions = [
		Vector2(160, 180), Vector2(400, 180), Vector2(640, 180), Vector2(880, 180), Vector2(1120, 180),
		Vector2(160, 360), Vector2(400, 360), Vector2(640, 360), Vector2(880, 360), Vector2(1120, 360),
		Vector2(160, 540), Vector2(400, 540), Vector2(640, 540), Vector2(880, 540), Vector2(1120, 540),
	]
	edges = [
		Vector2i(0, 1), Vector2i(1, 2), Vector2i(2, 3), Vector2i(3, 4),
		Vector2i(5, 6), Vector2i(6, 7), Vector2i(7, 8), Vector2i(8, 9),
		Vector2i(10, 11), Vector2i(11, 12), Vector2i(12, 13), Vector2i(13, 14),
		Vector2i(0, 5), Vector2i(5, 10),
		Vector2i(1, 6), Vector2i(6, 11),
		Vector2i(2, 7), Vector2i(7, 12),
		Vector2i(3, 8), Vector2i(8, 13),
		Vector2i(4, 9), Vector2i(9, 14),
	]
	target_numbers = {1: 1, 3: 2, 6: 3, 8: 4, 12: 5}
	start_index = 5
