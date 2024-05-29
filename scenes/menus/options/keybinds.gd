extends Option


@onready var KEYBINDS = load('res://scenes/menus/options/previews/keybinds.tscn')
var current_keybinds: Node


func _focus() -> void:
	# if u get this... how????
	if is_instance_valid(current_keybinds):
		return
	
	current_keybinds = KEYBINDS.instantiate()
	current_preview.add_child(current_keybinds)


func _unfocus() -> void:
	if is_instance_valid(current_keybinds):
		current_keybinds.queue_free()
