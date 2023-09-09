extends Event

func process_event(argument_1, argument_2):
	var char_string = argument_1.to_lower()
	
	match(char_string):
		"bf","boyfriend","player","player1":
			bf.play_animation("hey", true)
		"gf","girlfriend","player3":
			if gf: gf.play_animation("cheer", true)
		_:
			bf.play_animation("hey", true)
			if gf: gf.play_animation("cheer", true)
