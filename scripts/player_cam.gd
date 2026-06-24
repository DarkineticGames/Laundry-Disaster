extends Camera2D

var gui_width = 80
var shake_offset := Vector2.ZERO

func _process(delta):
	offset.x = -(gui_width / 2.0) * zoom.x + shake_offset.x
	offset.y = shake_offset.y
