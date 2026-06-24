extends CharacterBody2D

@onready var hit_animation_player: AnimationPlayer = $HitAnimationPlayer

@onready var animation = $AnimatedSprite2D

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

func _ready() -> void:
	add_to_group("Player")

func _physics_process(delta):
	
	if is_dead:
		return
	
	if Input.is_action_just_pressed("no_gravity"):
		gravity = 0
	if Input.is_action_just_pressed("return_gravity"):
		gravity = 1300.0
	
	# Gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# Get the input direction: -1, 0, 1
	var direction = Input.get_axis("walk_left", "walk_right")
	
	# Flip the sprite
	if direction > 0:
		animation.flip_h = false
	
	elif direction < 0:
		animation.flip_h = true
	# Play animation
	if is_on_floor():
		if direction == 0 :
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
		velocity.y = jump_velocity
		jump_buffer_timer = 0
		coyote_timer = 0

	# Variable jump height
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= 0.5


	move_and_slide()


func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Damage"):
		#print("get damaged")
		hit_animation_player.play("hit")
		HealthManager.decrease_health(1)


func die():

	is_dead = true

	$CollisionShape2D.set_deferred("disabled", true)
