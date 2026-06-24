extends Camera2D


var gui_width = 80

func _process(delta):
	offset.x = -(gui_width / 2.0) * zoom.x
