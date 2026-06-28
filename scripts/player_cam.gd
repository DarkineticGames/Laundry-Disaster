extends Camera2D

var gui_width = 80

func _process(_delta):
	var desired_offset := Vector2(-(gui_width / 2.0) * zoom.x, 0)
	offset = desired_offset.rotated(-rotation)
