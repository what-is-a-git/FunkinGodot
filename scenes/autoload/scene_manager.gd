extends CanvasLayer


@onready var transition: ColorRect = $transition
var tween: Tween


func switch_to(path: String, use_transition: bool = true) -> void:
	var tree := get_tree()
	
	if is_instance_valid(tween) and tween.is_running():
		tween.kill()
	
	tween = tree.create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT_IN)
	path = 'res://%s' % path
	
	if use_transition:
		tween.tween_property(transition.material, 'shader_parameter/progress', 1.0, 0.5)
		tween.tween_callback(func():
			tree.call_deferred('change_scene_to_file', path)
			
			if is_instance_valid(tween) and tween.is_running():
				tween.kill()
			
			tween = tree.create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT_IN)
			tween.tween_property(transition.material, 'shader_parameter/progress', 0.0, 0.5)
		)
	else:
		tree.call_deferred('change_scene_to_file', path)
