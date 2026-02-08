extends CanvasLayer

# SceneTransition.gd
signal scene_changed

@onready var color_rect = $ColorRect
@onready var animation_player = $AnimationPlayer

func change_scene(target: String):
	# Play Fade Out
	animation_player.play("fade_out")
	await animation_player.animation_finished
	
	# Change Scene
	get_tree().change_scene_to_file(target)
	
	# Play Fade In
	animation_player.play("fade_in")
	emit_signal("scene_changed")
