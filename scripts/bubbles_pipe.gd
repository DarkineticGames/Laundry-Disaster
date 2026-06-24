extends Node2D

@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var damage_zone: Area2D = $Sprite2D/damage_zone

var health_amount : int = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("Damage")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	animation.play("bubbels_on")
	


func _on_damage_zone_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		HealthManager.decrease_health(health_amount)
