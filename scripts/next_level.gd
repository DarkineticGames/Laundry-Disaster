extends Area2D
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

## Set "Next Level Scene" in the Inspector for THIS instance - drag the
## next level's .tscn file from the FileSystem panel into this field.
@export var next_level_scene: PackedScene

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and next_level_scene:
		audio_stream_player_2d.play()
		body.is_transitioning = true
		body.controls_locked = true
		body.velocity = Vector2.ZERO
		GameManager.gravity_direction = 1
		await TransitionScreen.play_transition(next_level_scene)
