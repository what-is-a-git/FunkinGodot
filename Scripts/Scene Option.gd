extends Node2D

@export var scene: String = "Binds Menu"

@export var description: String = ""

var is_bool = false

func open_option():
	Scenes.switch_scene("Options Menus/" + scene)
