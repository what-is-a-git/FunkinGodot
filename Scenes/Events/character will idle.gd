extends Event

func process_event(argument_1, argument_2):
	get_character_from_argument(argument_1).dances = argument_2.to_lower() == "true"
