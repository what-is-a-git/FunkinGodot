extends Node2D

@export var scene: String = "Charter"

@export var description: String = ""

var is_bool = false

func open_option():
	AudioHandler.stop_audio("Tools Menu")
	AudioHandler.play_audio("Confirm Sound")
	AudioHandler.stop_audio("Title Music")
	
	if scene == "Charter":
		Globals.song_name = "test"
		Globals.song_difficulty = "normal"
		Globals.freeplay = true
		
		var file := FileAccess.open(Paths.song_path(Globals.song_name, Globals.song_difficulty), FileAccess.READ)
		
		var test_json_conv = JSON.new()
		test_json_conv.parse(file.get_as_text())
		Globals.song = test_json_conv.get_data()["song"]
		
		if not "ui_skin" in Globals.song:
			Globals.song["ui_skin"] = "default"
		
		if not "gf" in Globals.song:
			Globals.song["gf"] = "gf"
		
		if not "stage" in Globals.song:
			Globals.song["stage"] = "stage"
		
		var inst = AudioHandler.get_node("Inst")
		
		inst.stream = null
	
		var song_path = "res://Assets/Songs/" + Globals.song_name.to_lower() + "/"
		
		if ResourceLoader.exists(song_path + "Inst-" + Globals.song_difficulty.to_lower() + ".ogg"):
			inst.stream = load(song_path + "Inst-" + Globals.song_difficulty.to_lower() + ".ogg")
		else:
			inst.stream = load(song_path + "Inst.ogg")
		
		inst.pitch_scale = Globals.song_multiplier
		inst.volume_db = 0
		
		if Globals.song["needsVoices"]:
			var voices = AudioHandler.get_node("Voices")
			
			voices.stream = null
			
			if ResourceLoader.exists(song_path + "Voices-" + Globals.song_difficulty.to_lower() + ".ogg"):
				voices.stream = load(song_path + "Voices-" + Globals.song_difficulty.to_lower() + ".ogg")
			else:
				voices.stream = load(song_path + "Voices.ogg")
			
			voices.pitch_scale = Globals.song_multiplier
			voices.volume_db = 0
	
	Scenes.switch_scene(scene)
