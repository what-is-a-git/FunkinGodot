extends Node2D

var offset:int = 0

var is_bool = false

var waiting_for_input = false

@onready var text = $Text
@onready var parent = $"../"

@export var description: String = ""

func _ready():
	var offset = Settings.get_data("offset")
	text.text = "OFFSET: " + str(offset)

func _process(_delta):
	if waiting_for_input:
		var offset = Settings.get_data("offset")
		
		if Input.is_action_just_pressed("ui_back"):
			open_option()
		if Input.is_action_just_pressed("ui_left") and !Input.is_action_pressed("ui_shift"):
			offset -= 1
		if Input.is_action_just_pressed("ui_right") and !Input.is_action_pressed("ui_shift"):
			offset += 1
		
		if Input.is_action_just_pressed("ui_left") and Input.is_action_pressed("ui_shift"):
			offset -= 10
		if Input.is_action_just_pressed("ui_right") and Input.is_action_pressed("ui_shift"):
			offset += 10
			
		if Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_right"):
			Settings.set_data("offset", offset)
			text.text = "OFFSET: " + str(offset)
		

func open_option():
	waiting_for_input = !waiting_for_input
	
	parent.can_move = !waiting_for_input
