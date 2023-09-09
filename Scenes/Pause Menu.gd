extends Control

var selected: int = 0
var showing = false

var tween: Tween

@onready var bg = $BG

@onready var resume = $Resume
@onready var restart_song = $"Restart Song"
@onready var options = $"Options"
@onready var exit_menu = $"Exit Menu"

@onready var song_name = $"Song Name"
@onready var song_difficulty = $"Song Difficulty"

func _ready():
	hide()

func _process(delta):
	if Input.is_action_just_pressed("ui_confirm") and Scenes.current_scene == "Gameplay" and !showing:
		get_tree().paused = true
		
		if is_instance_valid(tween) and tween.is_valid():
			tween.stop()
		
		set_pos_text(resume, 0 - selected, 1)
		set_pos_text(restart_song, 1 - selected, 1)
		set_pos_text(options, 2 - selected, 1)
		set_pos_text(exit_menu, 3 - selected, 1)
		
		bg.modulate.a = 0
		tween = create_tween().set_trans(Tween.TRANS_QUART).set_parallel()
		tween.tween_property(bg, "modulate:a", 0.9, 0.4)
		
		song_name.modulate.a = 0
		song_difficulty.modulate.a = 0
		
		song_name.position.y = 10
		song_difficulty.position.y = 40 # 10 + 30
		
		tween.tween_property(song_name, "modulate:a", 1.0, 0.4).set_delay(0.3)
		tween.tween_property(song_name, "position:y", 15, 0.4).set_delay(0.3)
		
		tween.tween_property(song_difficulty, "modulate:a", 1.0, 0.4).set_delay(0.5)
		tween.tween_property(song_difficulty, "position:y", 45, 0.4).set_delay(0.5)
		
		selected = 0
		show()
		on_show()
		showing = true
		refresh_bullshit()
		
		song_name.position.x = 1280 - (song_name.size.x + 20)
		song_difficulty.position.x = 1280 - (song_difficulty.size.x + 20)
		
		AudioHandler.get_node("Inst").stream_paused = true
		AudioHandler.get_node("Voices").stream_paused = true
	elif Input.is_action_just_pressed("ui_confirm") and showing:
		get_tree().paused = false
		hide()
		showing = false
		AudioHandler.get_node("Inst").stream_paused = false
		AudioHandler.get_node("Voices").stream_paused = false
		
		match(selected):
			1:
				get_tree().reload_current_scene()
				Globals.do_cutscenes = false
			2:
				OptionsSideBar.returning_scene = 'Gameplay'
				Scenes.switch_scene('Options Menu')
			3:
				if Globals.freeplay:
					Scenes.switch_scene("Freeplay")
				else:
					Scenes.switch_scene("Story Mode")
	
	if showing:
		set_pos_text(resume, 0 - selected, delta)
		set_pos_text(restart_song, 1 - selected, delta)
		set_pos_text(options, 2 - selected, delta)
		set_pos_text(exit_menu, 3 - selected, delta)
		
		if Input.is_action_just_pressed("ui_down") or Input.is_action_just_pressed("ui_up"):
			if Input.is_action_just_pressed("ui_down"):
				selected += 1
			if Input.is_action_just_pressed("ui_up"):
				selected -= 1
			
			selected = wrapi(selected, 0, 4)
			
			AudioHandler.play_audio("Scroll Menu")
			refresh_bullshit()

func on_show():
	song_name.text = Globals.song.song
	song_difficulty.text = Globals.songDifficulty.to_upper()

func refresh_bullshit():
	resume.modulate.a = 0.5
	restart_song.modulate.a = 0.5
	options.modulate.a = 0.5
	exit_menu.modulate.a = 0.5
	
	match(selected):
		0:
			resume.modulate.a = 1
		1:
			restart_song.modulate.a = 1
		2:
			options.modulate.a = 1
		3:
			exit_menu.modulate.a = 1

func set_pos_text(text, targetY, elapsed):
	var scaledY: float = remap(targetY, 0, 1, 0, 1.3)
	var lerpVal: float = clampf(elapsed * 9.6, 0.0, 1.0)
	
	# 120 = yMult, 720 = FlxG.height
	text.position.y = lerp(text.position.y, (scaledY * 120.0) + (720 * 0.48), lerpVal);
	text.position.x = lerp(text.position.x, (targetY * 20.0) + 90, lerpVal)
