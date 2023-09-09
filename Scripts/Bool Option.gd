extends Node2D

@export var save_name: String = "downscroll"
@export var value: bool = false

@export var description: String = ""

var is_bool = true

@onready var checkbox: AnimatedSprite2D = $Checkbox
@onready var text: Label = $Text

func _ready():
	value = Settings.get_data(save_name)
	update_checkbox()

func _process(delta: float) -> void:
	text.size = Vector2.ZERO
	checkbox.position = text.position + Vector2(text.size.x, 0.0) + Vector2(8.0, -12.0) + \
			Vector2(
				checkbox.sprite_frames.get_frame_texture('Unchecked', 0).get_width() / 2.0, 
				checkbox.sprite_frames.get_frame_texture('Unchecked', 0).get_height() / 2.0)

func update_checkbox():
	checkbox.stop()
	
	if value:
		checkbox.play("Checked")
	else:
		checkbox.play("Unchecked")

func open_option():
	value = !value
	
	if save_name == "vsync":
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if (value) else DisplayServer.VSYNC_DISABLED)
	
	if save_name == "memory_leaks":
		if value:
			Globals.leak_memory()
		else:
			Globals.unleak_memory()
