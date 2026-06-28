extends CanvasLayer
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

## Attach to the root CanvasLayer of your pause menu scene, then add this
## scene as a SECOND autoload (Project Settings > Autoload), named exactly
## "PauseMenu" - same way GameManager and HealthManager are already set up.

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS  # so buttons stay clickable while paused
	visible = false

## Connect your Resume button's "pressed" signal to this
func _on_resume_button_pressed() -> void:
	audio_stream_player_2d.play()
	GameManager.toggle_pause()


func _on_restart_button_pressed() -> void:
	audio_stream_player_2d.play()
	GameManager.gravity_direction = 1
	GameManager.toggle_pause()
	GameManager.player_die()
	GameManager.gravity_direction = 1


func _on_main_menu_pressed() -> void:
	audio_stream_player_2d.play()
	get_tree().paused = false
	visible = false
	GameManager.is_gameplay_active = false
	GameManager.toggle_pause()

	await TransitionScreen.play_transition(
		load("res://scenes/UI/main_menu.tscn"))
