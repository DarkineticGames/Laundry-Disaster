extends CanvasLayer

## Attach to the root CanvasLayer of your pause menu scene, then add this
## scene as a SECOND autoload (Project Settings > Autoload), named exactly
## "PauseMenu" - same way GameManager and HealthManager are already set up.

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS  # so buttons stay clickable while paused
	visible = false

## Connect your Resume button's "pressed" signal to this
func _on_resume_button_pressed() -> void:
	GameManager.toggle_pause()



func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_restart_button_pressed() -> void:
	GameManager.player_die()
