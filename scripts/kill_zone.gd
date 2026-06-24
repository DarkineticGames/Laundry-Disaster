extends Area2D

@onready var timer: Timer = $Timer

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		#print("you died! ")
		GameManager.player_die()
