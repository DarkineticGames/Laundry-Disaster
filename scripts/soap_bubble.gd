extends StaticBody2D

@export var respawn_time: float = 3.0       # how long until it comes back

@export var health_amount : int = 1

@onready var timer: Timer = $Timer
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var hurtbox: Area2D = $Hurtbox
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var is_popped: bool = false
var start_position: Vector2

func _ready() -> void:
	add_to_group("Damage")
	start_position = position
	timer.one_shot = true

func _on_hurtbox_body_entered(body: Node2D) -> void:
	#print("do i need to pop?")
	if body.is_in_group("Player") and not is_popped:
		#print("I poped!!")
		timer.start()

func _on_timer_timeout() -> void:
	_pop()

func _pop() -> void:
	is_popped = true

	collision_shape_2d.disabled = true
	hurtbox.monitoring = false
	
	animated_sprite.play("pop")

	await get_tree().create_timer(respawn_time).timeout
	_respawn()

func _respawn() -> void:
	is_popped = false
	position = start_position
	animated_sprite.play("respawn")
	collision_shape_2d.disabled = false
	hurtbox.monitoring = true
	
