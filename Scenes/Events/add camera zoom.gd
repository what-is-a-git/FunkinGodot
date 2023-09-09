extends Event

func process_event(argument_1, argument_2):
	game.camera.zoom.x += float(argument_1)
	game.camera.zoom.y += float(argument_1)
	
	game.ui.scale.x += float(argument_2)
	game.ui.scale.y += float(argument_2)
	
	game.position_hud()
