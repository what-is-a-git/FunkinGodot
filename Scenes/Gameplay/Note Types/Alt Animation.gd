extends Note

func note_hit() -> void:
	super()
	
	var in_game_character: Character = game.bf if is_player else game.dad
	
	if not in_game_character:
		return
	
	if character != 0:
		in_game_character.play_animation('sing%s-alt' % Globals.dir_to_animstr(direction).to_upper(), true, character)
	else:
		in_game_character.play_animation('sing%s-alt' % Globals.dir_to_animstr(direction).to_upper(), true)
