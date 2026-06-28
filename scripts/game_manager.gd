extends Node

var is_dead := false
var is_gameplay_active := false 
var gravity_direction := 1

@onready var finish_wash: AudioStreamPlayer2D = $FinishWash
@onready var pop: AudioStreamPlayer2D = $Pop
@onready var button_press: AudioStreamPlayer2D = $"Button-press"
@onready var timer_click: AudioStreamPlayer2D = $"timer-click"



func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta: float):
	if Input.is_action_just_pressed("pause"):
		if is_gameplay_active and not is_dead:
			toggle_pause()


func toggle_pause() -> void:
	get_tree().paused = not get_tree().paused
	PauseMenu.visible = get_tree().paused


func player_die():

	if is_dead:
		return

	is_dead = true
	
	var player = get_tree().get_first_node_in_group("Player")

	if player:
		player.die()
		gravity_direction = 1
		player.animation.play("die")
		finish_wash.play()
	gravity_direction = 1
	

	await get_tree().create_timer(0.6).timeout

	Engine.time_scale = 0.5

	await get_tree().create_timer(0.8, true, false, true).timeout

	Engine.time_scale = 1

	HealthManager.reset_health()

	

	await LoadingScreen.play_loading()

	is_dead = false
