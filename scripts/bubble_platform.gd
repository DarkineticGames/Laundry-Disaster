extends StaticBody2D

@export var respawn_time: float = 3.0       # how long until it comes back
@export var fade_duration: float = 0.4

@onready var timer: Timer = $Timer
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var area_2d: Area2D = $Area2D

var is_popped: bool = false

func _ready() -> void:
	timer.one_shot = true

func _on_area_2d_body_entered(body: Node2D) -> void:
	#print("do i need to pop?")
	if body.is_in_group("Player") and not is_popped:
		#print("I poped!!")
		timer.start()

func _on_timer_timeout() -> void:
	_pop()

func _pop() -> void:
	is_popped = true

	collision_shape_2d.disabled = true
	area_2d.monitoring = false

	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, fade_duration)

	await get_tree().create_timer(respawn_time).timeout
	_respawn()

func _respawn() -> void:
	is_popped = false
	collision_shape_2d.disabled = false
	area_2d.monitoring = true

	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, fade_duration)
