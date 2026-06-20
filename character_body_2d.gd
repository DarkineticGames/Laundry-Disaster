extends CharacterBody2D
@onready var animotion =$AnimatedSprite2D
@export var speed := 300.0
@export var acceleration := 2000.0
@export var friction := 2500.0
@onready var sprote = $AnimatedSprite2D

@export var jump_velocity := -500.0
@export var gravity := 1200.0

@export var coyote_time := 0.15
@export var jump_buffer_time := 0.15

var coyote_timer := 0.0
var jump_buffer_timer := 0.0

func _physics_process(delta):
	# Gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# Horizontal movement
	var direction := Input.get_axis("walk_left", "walk_right")

	if direction != 0:
		animotion.play("new_animation")
		velocity.x = move_toward(
			velocity.x,
			direction * speed,
			acceleration * delta
		)
	else:
		velocity.x = move_toward(
			velocity.x,
			0,
			friction * delta
		)

	# Coyote time
	if is_on_floor():
		coyote_timer = coyote_time
	else:
		coyote_timer -= delta

	# Jump buffer
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = jump_buffer_time
	else:
		jump_buffer_timer -= delta

	# Jump
	if jump_buffer_timer > 0 and coyote_timer > 0:
		velocity.y = jump_velocity
		jump_buffer_timer = 0
		coyote_timer = 0

	# Variable jump height
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= 0.5

	move_and_slide()
