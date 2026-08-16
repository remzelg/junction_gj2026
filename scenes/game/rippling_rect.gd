@tool # To view this in editor. Otherwise remove @tool keyword

extends ColorRect  # or whatever node type you're using

@export var node_2d: Node2D # Which node to apply this shader to

@onready var camera_2d := get_viewport().get_camera_2d()

func set_distortion_center(world_position: Vector2) -> void:
	if camera_2d == null: camera_2d = Camera2D.new()
	
	# Get the current viewport size
	var viewport_size: Vector2 = get_viewport_rect().size
	
	# Get the camera's center position (accounts for smoothing and limits)
	var camera_center: Vector2 = camera_2d.get_screen_center_position()
	
	# Calculate screen position (normalize to 0.0 - 1.0 range)
	var screen_position: Vector2 = (
		# First convert world position to screen coordinates
		(world_position - camera_center) * camera_2d.zoom +  # Apply camera zoom
		viewport_size / 2  # Center offset
	)
	
	# Convert to normalized coordinates (0-1 range)
	var normalized_position = screen_position / viewport_size
	
	# make sure material is ShaderMaterial
	material.set_shader_parameter("center", normalized_position)

# Example: Update center when mouse is clicked
func _process(delta):
	var world_pos = global_position
	set_distortion_center(world_pos)
