extends Area2D

var health_amount : int =1

func _ready() -> void:
	add_to_group("Damage")

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		#print("get damage ")
		HealthManager.decrease_health(health_amount)
