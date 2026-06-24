extends CharacterBody2D
var shake_strength := 0.0
@onready var animotion = $AnimatedSprite2D
@onready var sprote = $AnimatedSprite2D
@onready var camera = $Camera2D
@onready var flip_timer = $Timer

@export var speed := 300.0
@export var acceleration := 2000.0
@export var friction := 2500.0

@export var gravity_strength := 1200.0
@export var jump_velocity := -500.0

@export var coyote_time := 0.15
@export var jump_buffer_time := 0.15

var gravity_direction := 1
var controls_locked := false

var coyote_timer := 0.0
var jump_buffer_timer := 0.0

func _ready():
	flip_timer.wait_time = 5.0
	flip_timer.one_shot = false
	flip_timer.start()

	flip_timer.timeout.connect(flip_world)

func _physics_process(delta):
	if shake_strength > 0:
		camera.offset = Vector2(
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength)
		)

		shake_strength = move_toward(
			shake_strength,
			0.0,
			20.0 * delta
		)
	else:
		camera.offset = Vector2.ZERO

	if controls_locked:
		up_direction = Vector2.UP * -gravity_direction
		move_and_slide()
		return

	# Gravity
	if not is_on_floor():
		velocity.y += gravity_strength * gravity_direction * delta

	# Movement
	var direction := Input.get_axis("walk_left", "walk_right")
	if gravity_direction == -1:
		direction *= -1

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

	# Coyote Time
	if is_on_floor():
		coyote_timer = coyote_time
	else:
		coyote_timer -= delta

	# Jump Buffer
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = jump_buffer_time
	else:
		jump_buffer_timer -= delta

	# Jump

	if jump_buffer_timer > 0 and coyote_timer > 0:
		print("JUMP!")
		velocity.y = jump_velocity * gravity_direction
		jump_buffer_timer = 0
		coyote_timer = 0

	# Variable Jump Height
	if Input.is_action_just_released("jump"):
		if velocity.y * gravity_direction < 0:
			velocity.y *= 0.5

	# Tell Godot which way is up
	up_direction = Vector2.UP * gravity_direction

	move_and_slide()

func flip_world():
	controls_locked = true
	
	shake_strength = 8.0

	var tween = create_tween()

	tween.tween_property(
		camera,
		"rotation",
		camera.rotation + PI,
		0.5
	)
	tween.parallel().tween_property(
		sprote,
		"rotation",
		sprote.rotation + PI,
		0.5 )

	await tween.finished

	gravity_direction *= -1

	controls_locked = false
