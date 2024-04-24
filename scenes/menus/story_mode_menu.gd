extends Node2D


var active: bool = true


func _input(event: InputEvent) -> void:
	if not active:
		return
	if event.is_echo():
		return
	if not event.is_pressed():
		return
	if event.is_action('ui_cancel'):
		active = false
		GlobalAudio.get_player('MENU/CANCEL').play()
		SceneManager.switch_to('scenes/menus/main_menu.tscn')
