class_name Option extends Node2D


@onready var current_preview: Node2D = %current_preview
var selected: bool = false


func _select() -> void:
	print('Selected option %s!' % name)


func _focus() -> void:
	print('Focused option %s!' % name)


func _unfocus() -> void:
	print('Unfocused option %s!' % name)
