extends Event

var character_cache:Dictionary = {}

func setup_event(arg_1, arg_2):
	if !character_cache.has(arg_2) and ResourceLoader.exists("res://Scenes/Characters/" + arg_2 + ".tscn"):
		character_cache[arg_2] = load("res://Scenes/Characters/" + arg_2 + ".tscn")

func process_event(arg_1, arg_2):
	if character_cache.has(arg_2):
		var character_str = get_str_character_from_argument(arg_1)
		
		var old_gf = game.gf
		var old_bf = game.bf
		var old_dad = game.dad
		
		var stage = game.stage
		
		game.remove_child(stage)
		
		game.remove_child(old_gf)
		game.remove_child(old_bf)
		game.remove_child(old_dad)
		
		var character = character_cache[arg_2].instantiate()
		
		match(character_str):
			"gf":
				character.position = old_gf.position
				
				if old_dad == old_gf:
					game.dad = character
				
				old_gf.queue_free()
				game.gf = character
			"dad":
				character.position = old_dad.position
				
				if old_dad != old_gf or arg_2.starts_with("gf"):
					old_dad.queue_free()
				
				game.dad = character
				
				if arg_2.starts_with("gf"):
					character.position = old_gf.position
					old_gf.queue_free()
					game.gf = character
			_:
				character.position = old_bf.position
				old_bf.queue_free()
				game.bf = character
		
		game.add_child(game.stage)
		
		game.add_child(game.gf)
		game.add_child(game.bf)
		game.add_child(game.dad)
	else:
		print("Error: " + arg_2 + " does not exist as a character in the cache!")
