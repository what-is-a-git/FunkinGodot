extends Node2D

@export var save_name: String = "array_option"

@export var options: Array = ["option1", "option2", "option3"]

@export var description: String = ""

@export var base_name: String = "Array Option"

var value:String

var is_bool = false

@onready var text = $Text

func _ready():
	value = Settings.get_data(save_name)
	text.text = base_name + ": " + value.to_upper()

func open_option():
	var selected = 0
	
	for i in len(options):
		if options[i] == Settings.get_data(save_name):
			selected = i
	
	selected += 1
	
	if selected > len(options) - 1:
		selected = 0
	
	value = options[selected]
	
	Settings.set_data(save_name, options[selected])
	
	text.text = base_name + ": " + value.to_upper()
