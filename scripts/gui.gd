extends CanvasLayer


@onready var animated_knob: AnimatedSprite2D = $"control_panel/Animated-knob"
@onready var dm_arrow: Sprite2D = $"control_panel/DM-arrow"
@onready var label: Label = $Label

var rotation_cycle_timer := 0.0

func _ready():

	update_level_text()

	LevelManager.level_changed.connect(update_level_text)
	
	update_dm_arrow()

	HealthManager.health_changed.connect(update_dm_arrow)


func update_level_text():

	label.text = "LVL %02d" % LevelManager.current_level


func update_dm_arrow():

	var target_y : float
	var target_rotation : float = 0

	match HealthManager.current_health:

		4:
			target_y = -155

		3:
			target_y = -126

		2:
			target_y = -98

		1:
			target_y = -71

		0:
			target_y = -61
			target_rotation = -42

	var tween = create_tween()

	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)

	tween.parallel().tween_property(
		dm_arrow,
		"position:y",
		target_y,
		0.4
	)

	tween.parallel().tween_property(
		dm_arrow,
		"rotation_degrees",
		target_rotation,
		0.4
	)
	if HealthManager.current_health == 0:
		tween.finished.connect(GameManager.player_die)


func _process(delta):

	rotation_cycle_timer += delta

	if rotation_cycle_timer >= 20.0:
		rotation_cycle_timer -= 20.0

	var frame_index = int(rotation_cycle_timer / 1.25)

	animated_knob.frame = clamp(frame_index, 0, 15)
