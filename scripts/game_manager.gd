extends Node

var is_dead := false
var gravity_direction := 1

@onready var break_sfx: AudioStreamPlayer2D = $BreakSFX


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta: float):
	if Input.is_action_just_pressed("pause"):
		toggle_pause()

func toggle_pause() -> void:
	get_tree().paused = not get_tree().paused
	PauseMenu.visible = get_tree().paused


func pauseMenu():
	if pauseMenu().paused:
		PauseMenu.hide()

func player_die():

	if is_dead:
		return

	is_dead = true
	
	var player = get_tree().get_first_node_in_group("Player")

	if player:
		player.die()

	#break_sfx.play()
	player.animation.play("die")

	await get_tree().create_timer(0.6).timeout

	Engine.time_scale = 0.5

	await get_tree().create_timer(0.8, true, false, true).timeout

	Engine.time_scale = 1

	HealthManager.reset_health()

	gravity_direction = 1

	get_tree().reload_current_scene()

	is_dead = false
