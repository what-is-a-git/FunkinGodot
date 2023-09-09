extends Event

func process_event(argument_1, argument_2) -> void:
	game.default_camera_zoom = Globals.hxzoom_to_gdzoom(float(argument_1))
	game.default_hud_zoom = float(argument_2)
