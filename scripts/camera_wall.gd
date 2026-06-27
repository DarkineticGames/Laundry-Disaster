# camera_wall.gd
extends Area2D

# No logic needed here — this node is just a tagged Area2D.
# The camera detects it by group membership.

func _ready() -> void:
	add_to_group("CameraWall")
	# Make sure it doesn't interfere with physics
	monitorable = true
	monitoring = false
	collision_layer = 0  # doesn't block anything physically
	collision_mask = 0
