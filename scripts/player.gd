extends CharacterBody2D

@onready var hit_animation_player: AnimationPlayer = $HitAnimationPlayer
@onready var flip_pivot = $FlipPivot
@onready var animation = $FlipPivot/AnimatedSprite2D
@onready var hurtbox = $FlipPivot/Hurtbox
@onready var body_collision = $CollisionShape2D
@onready var camera : Camera2D = $PlayerCam
@onready var flip_timer = $Timer  

@onready var player_beeb: AudioStreamPlayer2D = $"player beeb"

@export var speed := 200.0
@export var acceleration := 2000.0
@export var friction := 2500.0
@export var jump_velocity := -500.0
@export var gravity := 1300.0
@export var coyote_time := 0.15
@export var jump_buffer_time := 0.15
@export var max_fall_speed := 900.0
@export var knockback_strength := 350.0
@export var knockback_vertical := -150.0
@export var freeze_duration := 0.1
@export var freeze_time_scale := 0.05


var controls_locked := false
var is_transitioning := false
var shake_strength := 0.0
var is_dead := false
var is_freezing := false
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
	if is_dead:
		return
	hit_animation_player.play("hit")
	_freeze_frame()

func _freeze_frame() -> void:
	if is_freezing:
		return
	is_freezing = true
	Engine.time_scale = freeze_time_scale
	# ignore_time_scale=true so this wait is always real-world 0.1s,
	# regardless of the slowdown we just applied
	await get_tree().create_timer(freeze_duration, true, false, true).timeout
	Engine.time_scale = 1.0
	is_freezing = false

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
	player_beeb.play()

	var tween = create_tween()
	tween.tween_property(camera, "rotation", camera.rotation + PI, 0.5)
	tween.parallel().tween_property(flip_pivot, "rotation", flip_pivot.rotation + PI, 0.5)
	await tween.finished

	if is_transitioning or is_dead:
		return  # already leaving this level - don't touch global gravity state on the way out

	GameManager.gravity_direction *= -1
	body_collision.global_position = hurtbox.global_position
	controls_locked = false

func _on_hurtbox_body_entered(body: Node2D) -> void:
	if is_dead:
		return
	if body.is_in_group("Damage"):
		HealthManager.decrease_health(body.health_amount)
		_apply_knockback(body)

func _apply_knockback(source: Node2D) -> void:
	var push_dir: float = sign(global_position.x - source.global_position.x)
	if push_dir == 0:
		push_dir = 1  # straight-down hits still get pushed somewhere, not stuck
	velocity.x = push_dir * knockback_strength
	velocity.y = knockback_vertical * GameManager.gravity_direction

func die():
	is_dead = true
	flip_timer.stop()
	animation.play("die")
	$CollisionShape2D.set_deferred("disabled", true)
	GameManager.gravity_direction = 1
