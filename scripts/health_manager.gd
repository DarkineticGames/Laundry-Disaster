extends Node

signal health_changed

var max_health : int = 4
var current_health : int

func _ready():
	reset_health()


func decrease_health(health_amount : int):
	current_health -= health_amount
	if current_health < 0:
		current_health = 0
	
	health_changed.emit()
	
	#print("decrease_health called")

func increase_health(health_amount : int):
	current_health += health_amount
	
	if current_health > max_health:
		current_health = max_health
	
	health_changed.emit()
	
	#print("increase health called")


func reset_health():

	current_health = max_health

	health_changed.emit()
