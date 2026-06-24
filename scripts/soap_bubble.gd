extends StaticBody2D

var health_amount : int = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("Damage")
