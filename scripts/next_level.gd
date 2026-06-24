extends Area2D

## Set "Next Level Scene" in the Inspector for THIS instance - drag the
## next level's .tscn file from the FileSystem panel into this field.
## No filename parsing, no FILE_BEGIN, no dependency on what current_scene
## happens to be - this works no matter how the scene is launched or wrapped.
@export var next_level_scene: PackedScene

func _on_body_entered(body: Node2D) -> void:
	#print("something is here")
	if body.is_in_group("Player") and next_level_scene:
		print("player is here")
		# Deferred so the scene tree isn't torn down mid-physics-callback.
		get_tree().change_scene_to_packed.call_deferred(next_level_scene)
