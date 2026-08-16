extends Sprite2D

const SPEED := 300.0
const HACK_RADIUS := 26.0
const START_INDEX := 5 # row 1, col 0

@onready var hacking_scene: HackingScene = owner

var current_index := START_INDEX
var target_index := START_INDEX
var current_direction := Vector2.ZERO
var queued_direction := Vector2.ZERO
var hacked_count := 0

var _positioned := false

func _process(delta: float) -> void:
	if not _positioned:
		position = hacking_scene.grid_nodes[current_index].position
		_positioned = true

	_animate()
	_read_input()
	_move(delta)
	if Input.is_action_just_pressed("ui_accept"):
		_try_hack()

func _animate() -> void:
	if randf() > 0.5:
		if frame < 165:
			frame = frame + 1
		else:
			frame = 0

func _read_input() -> void:
	if Input.is_action_just_pressed("move_up"):
		queued_direction = Vector2.UP
	elif Input.is_action_just_pressed("move_down"):
		queued_direction = Vector2.DOWN
	elif Input.is_action_just_pressed("move_left"):
		queued_direction = Vector2.LEFT
	elif Input.is_action_just_pressed("move_right"):
		queued_direction = Vector2.RIGHT

func _move(delta: float) -> void:
	if target_index == current_index:
		_try_leave_node()
		return

	var target_position: Vector2 = hacking_scene.grid_nodes[target_index].position
	var offset := target_position - position
	var step := SPEED * delta
	if offset.length() <= step:
		position = target_position
		current_index = target_index
		_try_leave_node()
	else:
		position += offset.normalized() * step

# Called on arrival at a node (and every frame while idle) to pick the next
# direction: prefer the last direction the player pressed, otherwise keep
# going straight, otherwise reverse back the way it came, otherwise stop.
func _try_leave_node() -> void:
	if hacking_scene.direction_valid(current_index, queued_direction):
		current_direction = queued_direction
		queued_direction = Vector2.ZERO
	elif not hacking_scene.direction_valid(current_index, current_direction):
		var reverse := -current_direction
		if hacking_scene.direction_valid(current_index, reverse):
			current_direction = reverse
		else:
			current_direction = Vector2.ZERO

	if current_direction != Vector2.ZERO:
		target_index = hacking_scene.neighbor_index(current_index, current_direction)
	else:
		target_index = current_index

func _try_hack() -> void:
	for node in hacking_scene.grid_nodes:
		if node.is_target and not node.hacked and node.position.distance_to(position) <= HACK_RADIUS:
			node.hack()
			hacked_count += 1
			hacking_scene.update_status(hacked_count)
			return
