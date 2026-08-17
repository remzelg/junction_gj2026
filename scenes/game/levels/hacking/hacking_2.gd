extends HackingScene

## A much larger, non-tree formation: two junctions each fork up/down/right,
## and the far end closes into two loops (top and bottom) instead of
## dead-ending, so there's more than one route to some targets. Two doors
## (target 1 and target 6) and one numbered rocket-jump marker (target 7)
## are woven in. Every edge is still a pure horizontal or vertical run.
func _init() -> void:
	node_positions = [
		Vector2(140, 360),  # 0: start
		Vector2(380, 360),  # 1: junction 1
		Vector2(380, 140),  # 2: target 2
		Vector2(380, 580),  # 3: target 3
		Vector2(620, 360),  # 4: target 1 (door A)
		Vector2(860, 360),  # 5: junction 2
		Vector2(860, 140),  # 6: waypoint (upper branch)
		Vector2(1100, 140), # 7: target 4
		Vector2(860, 580),  # 8: waypoint (lower branch)
		Vector2(1100, 580), # 9: target 5
		Vector2(1340, 360), # 10: junction 3
		Vector2(1340, 140), # 11: rocket marker (7)
		Vector2(1340, 580), # 12: target 6 (door B)
	]
	edges = [
		Vector2i(0, 1),
		Vector2i(1, 2),
		Vector2i(1, 3),
		Vector2i(1, 4),
		Vector2i(4, 5),
		Vector2i(5, 6),
		Vector2i(6, 7),
		Vector2i(5, 8),
		Vector2i(8, 9),
		Vector2i(5, 10),
		Vector2i(10, 11),
		Vector2i(10, 12),
		Vector2i(7, 11), # closes the upper loop: 5-6-7-11-10-5
		Vector2i(9, 12), # closes the lower loop: 5-8-9-12-10-5
	]
	target_numbers = {2: 2, 3: 3, 4: 1, 7: 4, 9: 5, 12: 6}
	rocket_numbers = {11: 7}
	start_index = 0
