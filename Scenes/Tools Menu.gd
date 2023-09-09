extends Node2D

var selected = 0

func _ready():
	AudioHandler.play_audio("Tools Menu")
	
	update_options()

func _process(delta):
	var up = Input.is_action_just_pressed("ui_up")
	var down = Input.is_action_just_pressed("ui_down")
	
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
	
	if Input.is_action_just_pressed("ui_accept"):
		get_child(selected).open_option()
	if Input.is_action_just_pressed("ui_cancel"):
		Scenes.switch_scene("Options Menu")
		AudioHandler.stop_audio("Tools Menu")
		AudioHandler.play_audio("Title Music")
	
	for i in get_child_count():
		set_pos_text(get_child(i), i - selected, delta)

func set_pos_text(text, targetY, elapsed):
	var scaledY = remap(targetY, 0.0, 1.0, 0.0, 1.3)
	
	var lerpVal = clamp(elapsed * 9.6, 0.0, 1.0)
	
	# 120 = yMult, 720 = FlxG.height
	text.position.y = lerp(text.position.y, (scaledY * 120.0) + (720.0 * 0.48), lerpVal);

	text.position.x = lerp(text.position.x, (targetY * 20.0) + 90.0, lerpVal)

func update_options():
	for option in get_children():
		if option == get_child(selected):
			option.modulate.a = 1
		else:
			option.modulate.a = 0.6
	
	AudioHandler.play_audio("Scroll Menu")
	
	Discord.update_presence("In the Tools Menu", "Selecting " + get_child(selected).name)
