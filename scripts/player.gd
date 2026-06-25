extends CharacterBody2D

@onready var hit_animation_player: AnimationPlayer = $HitAnimationPlayer
@onready var flip_pivot = $FlipPivot
@onready var animation = $FlipPivot/AnimatedSprite2D
@onready var hurtbox = $FlipPivot/Hurtbox
@onready var body_collision = $CollisionShape2D
@onready var camera = $PlayerCam   # was $Camera2D in your friend's scene
@onready var flip_timer = $Timer   # NEW NODE - add a Timer as a child of player

@export var speed := 200.0
@export var acceleration := 2000.0
@export var friction := 2500.0
@export var jump_velocity := -500.0
@export var gravity := 1300.0
@export var coyote_time := 0.15
@export var jump_buffer_time := 0.15
@export var max_fall_speed := 900.0


var controls_locked := false
var shake_strength := 0.0
var is_dead := false
var coyote_timer := 0.0
var jump_buffer_timer := 0.0

func _ready() -> void:
	add_to_group("Player")
	HealthManager.damaged.connect(_on_damaged)

	flip_timer.wait_time = 5.0
	flip_timer.one_shot = false
	flip_timer.start()
	flip_timer.timeout.connect(flip_world)

func _on_damaged() -> void:
	hit_animation_player.play("hit")

func _physics_process(delta):
	if is_dead:
		return

	# Camera shake - triggered by flip_world() below
	if shake_strength > 0:
		camera.offset = Vector2(
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength)
		)
		shake_strength = move_toward(shake_strength, 0.0, 20.0 * delta)
	else:
		camera.offset = Vector2.ZERO

	if controls_locked:
		# Pre-empt the upcoming flip so is_on_floor() doesn't glitch mid-rotation
		up_direction = Vector2.UP * -GameManager.gravity_direction
		move_and_slide()
		return

	if Input.is_action_just_pressed("no_gravity"):
		gravity = 0
	if Input.is_action_just_pressed("return_gravity"):
		gravity = 1300.0

	# Gravity
	if not is_on_floor():
		velocity.y += gravity * GameManager.gravity_direction * delta
		
		velocity.y = clamp(
		velocity.y,
		-max_fall_speed,
		max_fall_speed
	)

	# Get the input direction: -1, 0, 1
	var direction = Input.get_axis("walk_left", "walk_right")
	if GameManager.gravity_direction == -1:
		direction *= -1

	# Flip the sprite - inverted when upside-down, since rotating a sprite
	# 180 degrees already turns a horizontal mirror into an effective
	# vertical one, so we have to swap which way "flip_h" points to compensate.
	# No "direction == 0" case on purpose - flip_h keeps its last value while idle.
	if direction > 0:
		animation.flip_h = (GameManager.gravity_direction == -1)
	elif direction < 0:
		animation.flip_h = (GameManager.gravity_direction != -1)

	# Play animation
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
		velocity.y = jump_velocity * GameManager.gravity_direction
		jump_buffer_timer = 0
		coyote_timer = 0

	# Variable jump height
	if Input.is_action_just_released("jump") and velocity.y * GameManager.gravity_direction < 0:
		velocity.y *= 0.5

	# Tell Godot which way is "up" so is_on_floor() stays correct
	up_direction = Vector2.UP * GameManager.gravity_direction

	move_and_slide()

func flip_world():
	controls_locked = true
	shake_strength = 8.0

	var tween = create_tween()
	tween.tween_property(camera, "rotation", camera.rotation + PI, 0.5)
	tween.parallel().tween_property(flip_pivot, "rotation", flip_pivot.rotation + PI, 0.5)
	await tween.finished

	GameManager.gravity_direction *= -1
	body_collision.global_position = hurtbox.global_position
	controls_locked = false

func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Damage"):
		HealthManager.decrease_health(body.health_amount)

func die():
	is_dead = true
	$CollisionShape2D.set_deferred("disabled", true)
