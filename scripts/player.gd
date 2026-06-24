extends CharacterBody2D

@onready var hit_animation_player: AnimationPlayer = $HitAnimationPlayer
@onready var animation = $AnimatedSprite2D
@onready var camera = $PlayerCam
@onready var flip_timer = $FlipTimer

@export var speed := 200.0
@export var acceleration := 2000.0
@export var friction := 2500.0

@export var jump_velocity := -500.0
@export var gravity := 1300.0

@export var coyote_time := 0.15
@export var jump_buffer_time := 0.15

var is_dead := false

var coyote_timer := 0.0
var jump_buffer_timer := 0.0

var gravity_direction := 1
var controls_locked := false
var shake_strength := 0.0

func _ready() -> void:
	add_to_group("Player")

	flip_timer.timeout.connect(flip_world)

func _process(delta):

	if shake_strength > 0:
		camera.shake_offset = Vector2(
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength)
		)

		shake_strength = move_toward(
			shake_strength,
			0.0,
			20.0 * delta
		)
	else:
		camera.shake_offset = Vector2.ZERO

func _physics_process(delta):

	if is_dead:
		return

	if controls_locked:
		up_direction = Vector2.UP * gravity_direction
		move_and_slide()
		return

	# Gravity
	if not is_on_floor():
		velocity.y += gravity * gravity_direction * delta

	# Movement
	var direction = Input.get_axis("walk_left", "walk_right")

	if gravity_direction == -1:
		direction *= -1

	# Sprite facing
	if direction > 0:
		animation.flip_h = false
	elif direction < 0:
		animation.flip_h = true

	# Animations
	if is_on_floor():
		if direction == 0:
			animation.play("idle")
	else:
		animation.play("jump")

	if direction != 0:
		animation.play("walk")

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
		velocity.y = jump_velocity * gravity_direction
		jump_buffer_timer = 0
		coyote_timer = 0

	# Variable Jump Height
	if Input.is_action_just_released("jump"):
		if velocity.y * gravity_direction < 0:
			velocity.y *= 0.5

	up_direction = Vector2.UP * gravity_direction

	move_and_slide()

func flip_world():

	print("FLIP!")

	controls_locked = true

	# Shake before flip
	shake_strength = 8.0

	await get_tree().create_timer(0.6).timeout

	var tween = create_tween()

	tween.parallel().tween_property(
		camera,
		"rotation",
		camera.rotation + PI,
		0.5
	)

	tween.parallel().tween_property(
		animation,
		"rotation",
		animation.rotation + PI,
		0.5
	)

	await tween.finished

	gravity_direction *= -1

	controls_locked = false

func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Damage"):
		hit_animation_player.play("hit")
		HealthManager.decrease_health(1)

func die():
	is_dead = true
	$CollisionShape2D.set_deferred("disabled", true)
