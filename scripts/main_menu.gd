extends CanvasLayer

@onready var laundry: AnimatedSprite2D = $MainMenu/laundry
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $"../AudioStreamPlayer2D"

func _ready() -> void:
	visible = true
	GameManager.is_gameplay_active = false
	get_tree().paused = false
	PauseMenu.visible = false

func _on_play_pressed() -> void:
	visible = false
	audio_stream_player_2d.play()
	GameManager.gravity_direction = 1
	GameManager.is_gameplay_active = true
	await TransitionScreen.play_transition(
		load("res://scenes/LVLs/lvl_1.tscn")
	)


func _on_quit_button_pressed() -> void:
	get_tree().quit()
