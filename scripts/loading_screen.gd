extends CanvasLayer

@onready var color_rect: ColorRect = $ColorRect
@onready var label: Label = $Label
@onready var knob: AnimatedSprite2D = $knob
@onready var timer: Timer = $Timer

func _ready():
	#process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

func play_loading():
	knob.visible = false
	label.visible = false
	knob.modulate.a = 1.0
	label.modulate.a = 1.0
	knob.stop()
	knob.frame = 0

	visible = true
	label.visible = false
	knob.visible = false
	color_rect.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(color_rect, "modulate:a", 1.0, 0.4)
	await tween.finished
	label.visible = true
	knob.visible = true
	knob.play("crazy_knob")

	timer.start()
	await timer.timeout

	get_tree().reload_current_scene()

	# reload_current_scene() is deferred - it schedules the swap rather than
	# doing it instantly, so we wait a couple of frames here to make sure the
	# new scene has actually finished loading and running its _ready() calls
	# before we start revealing it. Otherwise the fade-out can start while
	# the OLD (dead) scene is still what's behind the ColorRect.
	await get_tree().process_frame
	await get_tree().process_frame

	var fade_out := create_tween()
	fade_out.tween_property(color_rect, "modulate:a", 0.0, 0.5)
	fade_out.parallel().tween_property(label, "modulate:a", 0.0, 0.5)
	fade_out.parallel().tween_property(knob, "modulate:a", 0.0, 0.5)
	GameManager.gravity_direction = 1
	await fade_out.finished
	visible = false
