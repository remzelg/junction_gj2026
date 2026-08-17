extends HackingScene

## A zigzagging chain rather than a branching tree, plus a two-segment
## right-angle shortcut (via waypoint 10) that turns it into an actual
## (non-tree) graph with an alternate route — every edge is still a pure
## horizontal or vertical run.
func _init() -> void:
	node_positions = [
		Vector2(120, 540),  # 0: start
		Vector2(320, 540),  # 1: target 3
		Vector2(320, 320),  # 2: waypoint
		Vector2(520, 320),  # 3: target 1 (door)
		Vector2(520, 120),  # 4: waypoint
		Vector2(720, 120),  # 5: target 4
		Vector2(720, 340),  # 6: waypoint
		Vector2(920, 340),  # 7: target 2
		Vector2(920, 560),  # 8: waypoint
		Vector2(1120, 560), # 9: target 5
		Vector2(320, 340),  # 10: shortcut bend waypoint
	]
	edges = [
		Vector2i(0, 1),
		Vector2i(1, 2),
		Vector2i(2, 3),
		Vector2i(3, 4),
		Vector2i(4, 5),
		Vector2i(5, 6),
		Vector2i(6, 7),
		Vector2i(7, 8),
		Vector2i(8, 9),
		Vector2i(1, 10), # shortcut leg 1: straight up from the first target
		Vector2i(10, 6),  # shortcut leg 2: straight across to waypoint 6
	]
	target_numbers = {1: 3, 3: 1, 5: 4, 7: 2, 9: 5}
	start_index = 0
