class_name Event extends Node

# cool variables :D
@onready var game: Gameplay = $"../"

@onready var bf: Character = game.bf
@onready var dad: Character = game.dad
@onready var gf: Character = game.gf

# called when the event triggers in game
func process_event(argument_1, argument_2):
	pass

# called with arguments for all events of this type at song startup
# (for setting up shit like character caches)
func setup_event(argument_1, argument_2):
	pass

# easy way to convert string arguments to characters :D
func get_character_from_argument(argument) -> Node2D:
	match(argument.to_lower()):
		"girlfriend","gf","player3","2":
			return gf
		"dad","opponent","player2","1","0":
			return dad
		_:
			return bf

# funny thing like above, but for strings
func get_str_character_from_argument(argument) -> String:
	match(argument.to_lower()):
		"girlfriend","gf","player3","2":
			return "gf"
		"dad","opponent","player2","1","0":
			return "dad"
		_:
			return "bf"
