extends Node

signal level_changed

var current_level : int = 1:
	set(value):
		current_level = value
		level_changed.emit()
