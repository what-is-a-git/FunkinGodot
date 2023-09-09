extends Event

func process_event(argument_1, argument_2):
	var character: Character = get_character_from_argument(argument_2)
	
	character.timer = 0
	character.play_animation(argument_1, true)
	character.special_anim = true
