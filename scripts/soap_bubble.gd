extends StaticBody2D

@export var respawn_time: float = 5.0     # how long until it comes back
@export var health_amount : int = 1

@onready var timer: Timer = $Timer
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var hurtbox: Area2D = $Hurtbox
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var is_popped: bool = false
var start_position: Vector2

func _ready() -> void:
	add_to_group("Damage")
	animated_sprite.play("default")
	start_position = position
	timer.one_shot = true

func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and not is_popped:
		_pop()

func _on_timer_timeout() -> void:
	_respawn()

func _pop() -> void:
	if is_popped:
		return
	is_popped = true
	collision_shape_2d.set_deferred("disabled", true)
	hurtbox.set_deferred("monitoring", false)

	animated_sprite.play("pop")
	await animated_sprite.animation_finished
	visible = false

	timer.wait_time = respawn_time
	timer.start()

func _respawn() -> void:
	visible = true
	is_popped = false
	position = start_position
	collision_shape_2d.set_deferred("disabled", false)
	hurtbox.set_deferred("monitoring", true)
	animated_sprite.play("respawn")
	await animated_sprite.animation_finished
	animated_sprite.play("default")
