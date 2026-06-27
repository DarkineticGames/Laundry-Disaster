extends CanvasLayer

@onready var color_rect: ColorRect = $ColorRect
@onready var label: Label = $Label
@onready var washing_machine: AnimatedSprite2D = $washing_machine
@onready var timer: Timer = $Timer

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

func play_transition(next_scene: PackedScene) -> void:
	washing_machine.visible = false
	label.visible = false
	washing_machine.modulate.a = 1.0
	label.modulate.a = 1.0
	washing_machine.stop()
	washing_machine.frame = 0

	visible = true
	color_rect.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(color_rect, "modulate:a", 1.0, 0.4)
	await tween.finished
	label.visible = true
	washing_machine.visible = true
	washing_machine.play("spinning")

	timer.start()
	await timer.timeout

	get_tree().change_scene_to_packed.call_deferred(next_scene)

	# change_scene_to_packed is deferred - same reasoning as the loading
	# screen's reload_current_scene fix. Wait for it to actually finish
	# swapping before starting the reveal, so we don't catch a glimpse of
	# the OLD level while fading out.
	await get_tree().process_frame
	await get_tree().process_frame

	var fade_out := create_tween()
	fade_out.tween_property(color_rect, "modulate:a", 0.0, 0.5)
	fade_out.parallel().tween_property(label, "modulate:a", 0.0, 0.5)
	fade_out.parallel().tween_property(washing_machine, "modulate:a", 0.0, 0.5)

	await fade_out.finished
	visible = false
