extends Node2D

var value: int = 0

var is_bool: bool = false

var waiting_for_input: bool = false

@onready var text: Label = $Text
@onready var parent = $"../"

@export var description: String = ""

func _ready() -> void:
	var fps_cap: int = Settings.get_data("fps_cap")
	text.text = "FPS CAP: " + str(fps_cap)
	Engine.max_fps = fps_cap

func _process(_delta: float) -> void:
	if waiting_for_input:
		var fps_cap: int = Settings.get_data("fps_cap")
		
		if Input.is_action_just_pressed("ui_back"):
			open_option()
		if Input.is_action_just_pressed("ui_left") and !Input.is_action_pressed("ui_shift"):
			fps_cap -= 5
		if Input.is_action_just_pressed("ui_right") and !Input.is_action_pressed("ui_shift"):
			fps_cap += 5
		
		if Input.is_action_just_pressed("ui_left") and Input.is_action_pressed("ui_shift"):
			fps_cap -= 10
		if Input.is_action_just_pressed("ui_right") and Input.is_action_pressed("ui_shift"):
			fps_cap += 10
		
		fps_cap = clamp(fps_cap, 0, 1000)
			
		if Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_right"):
			Settings.set_data("fps_cap", fps_cap)
			text.text = "FPS CAP: " + str(fps_cap)
			Engine.max_fps = fps_cap
	
	

func open_option() -> void:
	waiting_for_input = !waiting_for_input
	parent.can_move = !waiting_for_input
