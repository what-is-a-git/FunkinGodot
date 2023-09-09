extends Event

func process_event(argument_1, argument_2):
	get_character_from_argument(argument_1).timer = 0
	get_character_from_argument(argument_1).play_animation(argument_2, true)
