extends Node

signal health_changed
signal damaged  # emitted specifically when health goes DOWN - separate from
				 # health_changed so listeners don't have to guess direction

var max_health : int = 4
var current_health : int

func _ready() -> void:
	reset_health()

func decrease_health(health_amount : int) -> void:
	current_health -= health_amount

	if current_health < 0:
		current_health = 0

	damaged.emit()
	health_changed.emit()

func increase_health(health_amount : int) -> void:
	current_health += health_amount

	if current_health > max_health:
		current_health = max_health

	health_changed.emit()

func reset_health() -> void:
	current_health = max_health
	health_changed.emit()
