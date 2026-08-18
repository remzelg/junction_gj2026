extends Sprite2D

const SPEED := 200.0
const HACK_RADIUS := 40.0
const PingScene := preload("res://scenes/game/levels/hacking/ping.tscn")
## Extra room beyond the outermost node positions the camera is allowed to
## pan into, so edge nodes aren't pressed right up against the viewport edge.
const CAMERA_MARGIN := 120.0

@onready var hacking_scene: HackingScene = owner
@onready var camera: Camera2D = $Camera2D

var current_index := 0
var target_index := 0
var current_direction := Vector2.ZERO
var queued_direction := Vector2.ZERO
var hacked_count := 0

var _positioned := false

func _ready() -> void:
	current_index = hacking_scene.start_index
	target_index = current_index
	_configure_camera()

# The camera's pan limits are hardcoded in hacking_indicator.tscn, sized for
# the original single grid layout. Since each level now defines its own
# graph (possibly larger or differently shaped), size them here instead from
# this level's actual node bounds so nothing ends up unreachable off-screen.
func _configure_camera() -> void:
	var bounds := hacking_scene.get_graph_bounds().grow(CAMERA_MARGIN)
	camera.limit_left = int(bounds.position.x)
	camera.limit_top = int(bounds.position.y)
	camera.limit_right = int(bounds.position.x + bounds.size.x)
	camera.limit_bottom = int(bounds.position.y + bounds.size.y)

func _process(delta: float) -> void:
	if not _positioned:
		position = hacking_scene.grid_nodes[current_index].position
		_positioned = true

	_animate()
	_read_input()
	_move(delta)
	if Input.is_action_just_pressed("ui_accept"):
		_spawn_ping()
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

func _spawn_ping() -> void:
	var ping := PingScene.instantiate()
	add_child(ping)
	ping.get_node("ColorRect").material.set_shader_parameter("spawn_time", Time.get_ticks_msec() / 1000.0)
	get_tree().create_timer(0.85).timeout.connect(ping.queue_free)

func _try_hack() -> void:
	for node in hacking_scene.grid_nodes:
		if node.position.distance_to(position) > HACK_RADIUS:
			continue
		if node.can_hack():
			_play_success_sound()
			node.hack()
			hacked_count += 1
			hacking_scene.node_triggered.emit(node.number)
			if hacked_count >= hacking_scene.target_count:
				hacking_scene.all_nodes_triggered.emit()
			return
		if node.can_trigger():
			_play_success_sound()
			hacking_scene.rocket_triggered.emit(node.number)
			return

func _play_success_sound() -> void:
	$AudioStreamPlayer2D.stream = load("res://assets/sound/success_2.wav")
	$AudioStreamPlayer2D.play()
