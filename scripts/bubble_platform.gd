extends StaticBody2D

@export var respawn_time: float = 3.0       # how long until it comes back
@export var sink_distance := 8.0
@export var sink_duration := 0.15

@onready var timer: Timer = $Timer
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var area_2d: Area2D = $Area2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var is_popped: bool = false
var start_position: Vector2

func _ready() -> void:
	start_position = position
	timer.one_shot = true

func _on_area_2d_body_entered(body: Node2D) -> void:
	#print("do i need to pop?")
	if body.is_in_group("Player") and not is_popped:
		#print("I poped!!")
		timer.start()

func _on_timer_timeout() -> void:
	await _sink()
	_pop()

func _pop() -> void:
	is_popped = true
	GameManager.pop.play()

	collision_shape_2d.disabled = true
	area_2d.monitoring = false
	
	animated_sprite.play("pop")

	await get_tree().create_timer(respawn_time).timeout
	_respawn()

func _respawn() -> void:
	is_popped = false
	position = start_position
	animated_sprite.play("respawn")
	collision_shape_2d.disabled = false
	area_2d.monitoring = true
	


func _sink():
	var sink_direction = Vector2.DOWN * GameManager.gravity_direction

	var tween := create_tween()

	tween.tween_property(
		self,
		"position",
		start_position + sink_direction * sink_distance,
		sink_duration
	)

	await tween.finished
