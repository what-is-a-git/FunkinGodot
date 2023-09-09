extends Event

func process_event(argument_1, argument_2) -> void:
	var zoom: float = float(argument_1)
	var duration: float = float(argument_2) / Globals.song_multiplier
	
	game.default_camera_zoom = zoom
	
	if duration > 0.0:
		var tween: Tween = create_tween().set_trans(Tween.TRANS_QUAD)
		tween.tween_property(game.camera, 'zoom', Vector2(zoom, zoom), duration)
	else:
		game.camera.zoom = Vector2(zoom, zoom)
