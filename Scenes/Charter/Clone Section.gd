extends Button

@onready var game = $"../../../"
@onready var section = $"../Section"

func clone():
	game.clone_section(int(section.text))
