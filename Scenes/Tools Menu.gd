extends Node2D


var selected = 0


func _ready() -> void:
	AudioHandler.play_audio('Tools Menu')
	
	update_options()


func _process(delta: float) -> void:
	var up := Input.is_action_just_pressed('ui_up')
	var down := Input.is_action_just_pressed('ui_down')
	
	if up or down:
		if up:
			selected -= 1
		if down:
			selected += 1
		
		if selected < 0:
			selected = get_child_count() - 1
		if selected > get_child_count() - 1:
			selected = 0
		
		update_options()
	
	if Input.is_action_just_pressed('ui_accept'):
		get_child(selected).open_option()
	if Input.is_action_just_pressed('ui_cancel'):
		Scenes.switch_scene('Options Menu')
		AudioHandler.stop_audio('Tools Menu')
		AudioHandler.play_audio('Title Music')
	
	for i in get_child_count():
		Globals.position_menu_alphabet(get_child(i), i - selected, delta)


func update_options() -> void:
	for option in get_children():
		if option == get_child(selected):
			option.modulate.a = 1
		else:
			option.modulate.a = 0.6
	
	AudioHandler.play_audio('Scroll Menu')
