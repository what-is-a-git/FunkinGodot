class_name BaseOptionsSection extends Node2D


@onready var timer: Timer = $timer
@onready var categories: HBoxContainer = %categories
@onready var camera: Camera2D = %camera

var selected: int = 0
var alive: bool = false:
	set(value):
		visible = value
		
		if value:
			_activate()
	get:
		return visible
var active: bool = false


func _input(event: InputEvent) -> void:
	if not (active and alive):
		return
	if not event.is_pressed():
		return
	if event.is_action('ui_cancel'):
		get_viewport().set_input_as_handled()
		
		GlobalAudio.get_player('MENU/CANCEL').play()
		active = false
		categories.active = true
		categories.options_menu.active = true
		categories._tween_back(self)
		return


func _activate() -> void:
	timer.start()


func _on_timer_timeout() -> void:
	active = true
