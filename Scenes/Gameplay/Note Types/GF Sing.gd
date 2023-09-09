extends Note

func note_hit() -> void:
	super()
	
	if not game.gf:
		return
	
	game.gf.timer = 0.0
	
	if not is_alt:
		if character != 0:
			game.gf.play_animation("sing" + Globals.dir_to_animstr(direction).to_upper(), true, character)
		else:
			game.gf.play_animation("sing" + Globals.dir_to_animstr(direction).to_upper(), true)
	else:
		if character != 0:
			game.gf.play_animation("sing" + Globals.dir_to_animstr(direction).to_upper() + "-alt", true, character)
		else:
			game.gf.play_animation("sing" + Globals.dir_to_animstr(direction).to_upper() + "-alt", true)
