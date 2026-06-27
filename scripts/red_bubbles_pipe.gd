extends Node2D



@onready var large_particles: GPUParticles2D = $Bubbles/GPUParticles2D
@onready var medium_particles: GPUParticles2D = $Bubbles/GPUParticles2DMid
@onready var small_particles: GPUParticles2D = $Bubbles/GPUParticles2DSmall

@onready var kill_zone: Area2D = $bubbles_Hurtbox/kill_zone


@export var active_time := 1000
@export var cooldown_time := 0.001
@export var small_to_mid_delay := 0.3
@export var mid_to_large_delay := 0.1


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("Damage")
	turn_off_everything()
	start_cycle()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	


func turn_off_everything():
	small_particles.emitting = false
	medium_particles.emitting = false
	large_particles.emitting = false

	kill_zone.monitoring = false


func turn_on_bubbles():
	small_particles.emitting = true

	await get_tree().create_timer(small_to_mid_delay).timeout

	medium_particles.emitting = true

	await get_tree().create_timer(mid_to_large_delay).timeout

	large_particles.emitting = true

	kill_zone.monitoring = true


func start_cycle() -> void:
	while true:

		await turn_on_bubbles()

		
		await get_tree().create_timer(active_time).timeout

		
		turn_off_everything()

		
		await get_tree().create_timer(cooldown_time).timeout
