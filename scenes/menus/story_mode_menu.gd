extends Control


@onready var songs: Control = %songs
@onready var weeks: Control = %weeks
@onready var difficulties: Control = %difficulties

var active: bool = true


func _process(delta: float) -> void:
	var target_y: float = 16.0 - weeks.get_child(weeks.selected).position.y
	weeks.position.y = lerpf(weeks.position.y, target_y, minf(delta * 6.0, 1.0))


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
	if event.is_action('ui_up') or event.is_action('ui_down'):
		var movement: int = int(Input.get_axis('ui_up', 'ui_down'))
		weeks.selected = wrapi(weeks.selected + movement, 0, weeks.get_child_count())
		
		if movement != 0:
			GlobalAudio.get_player('MENU/SCROLL').play()
