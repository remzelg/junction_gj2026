extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const SLIDE_MIN_SPEED = 150.0
const SLIDE_FRICTION = 400.0

## All animations in assets/player are drawn with the character facing right.
enum Facing { FORWARD, BACKWARD }

const ANIMATION_TEXTURES := {
	"idle": preload("res://assets/player/idle.png"),
	"crouch": preload("res://assets/player/crouch.png"),
	"run": preload("res://assets/player/run.png"),
}

const ANIMATION_HFRAMES := {
	"idle": 4,
	"crouch": 6,
	"run": 8,
}

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var facing: Facing = Facing.FORWARD

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		set_facing(Facing.BACKWARD if direction < 0 else Facing.FORWARD)

	var crouching := is_on_floor() and Input.is_action_pressed("ui_down")
	var sliding := crouching and absf(velocity.x) > SLIDE_MIN_SPEED

	if sliding:
		# Keep moving on residual momentum; input can't steer while sliding.
		velocity.x = move_toward(velocity.x, 0, SLIDE_FRICTION * delta)
	elif crouching:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	elif direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	if not is_on_floor() or crouching:
		set_crouch_held()
	else:
		set_animation("run" if direction else "idle")

	move_and_slide()

## Plays the named AnimationPlayer animation ("idle", "crouch", or "run"),
## swapping the sprite to that animation's spritesheet and frame count first.
func set_animation(anim_name: String) -> void:
	if sprite.texture != ANIMATION_TEXTURES[anim_name]:
		sprite.texture = ANIMATION_TEXTURES[anim_name]
		sprite.hframes = ANIMATION_HFRAMES[anim_name]
	if animation_player.current_animation != anim_name or not animation_player.is_playing():
		animation_player.play(anim_name)

## Plays the crouch animation once and holds on its last frame (rather than
## looping, like set_animation("crouch") would) — for holding down while
## grounded, as opposed to being airborne.
func set_crouch_held() -> void:
	if sprite.texture != ANIMATION_TEXTURES["crouch"]:
		sprite.texture = ANIMATION_TEXTURES["crouch"]
		sprite.hframes = ANIMATION_HFRAMES["crouch"]
	if animation_player.current_animation == "run":
		animation_player.play("crouch")

## Sets which way the character sprite faces. Animations are authored facing
## right (Facing.FORWARD); Facing.BACKWARD mirrors the sprite horizontally.
func set_facing(direction: Facing) -> void:
	facing = direction
	sprite.flip_h = facing == Facing.BACKWARD
