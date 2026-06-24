extends Node

@export var level_number : int = 1

func _ready():

	LevelManager.current_level = level_number
