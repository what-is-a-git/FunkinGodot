extends Node2D

var save_name = "hitsound"

@export var value: String = "osu mania"

@export var description: String = ""

var is_bool = false

@onready var text = $Text

func _ready():
	value = Settings.get_data(save_name)
	text.text = "HITSOUND: " + value.to_upper()

func open_option():
	var dir := DirAccess.open("res://Assets/Sounds/Hitsounds/")
	
	dir.list_dir_begin() # TODOConverter3To4 fill missing arguments https://github.com/godotengine/godot/pull/40547
	
	var hitsounds = []
	
	while true:
		var file = dir.get_next()
		
		if file == "":
			break
		elif file.ends_with(".ogg"):
			hitsounds.append(file.replace(".ogg", ""))
	
	if hitsounds.find(value) != -1:
		if len(hitsounds) - 1 >= hitsounds.find(value) + 1:
			value = hitsounds[hitsounds.find(value) + 1]
		else:
			value = hitsounds[0]
	else:
		value = hitsounds[0]
	
	text.text = "HITSOUND: " + value.to_upper()
	
	Settings.set_data(save_name, value)
	
	AudioHandler._ready()
