extends Node2D

@onready var week_template = $"Weeks/Week Template"
@onready var weeks_node = $Weeks

@onready var week_name = $"Main UI/Week Name"

@onready var week_score = $"Main UI/Week Score"

@onready var left_arrow = $"Main UI/Left Arrow"
@onready var right_arrow = $"Main UI/Right Arrow"
@onready var difficulty_sprite = $"Main UI/Difficulty"

@onready var dad = $"Main UI/Characters/dad"
@onready var bf = $"Main UI/Characters/bf"
@onready var gf = $"Main UI/Characters/gf"

@onready var bg = $"Main UI/Yellow Thingy"

var selected: int = 0

var selected_difficulty: int = 1
var difficulties: Array = ["easy", "normal", "hard"]

var weeks = [
	"week0",
	"week1",
	"week2",
	"week3",
	"week4",
	"week5",
	"week6",
	"week7",
	"weekTest",
]

var tween: Tween
@onready var icon = $"Main UI/Icons/Icon"

func _ready():
	if not AudioHandler.get_node("Title Music").playing:
		AudioHandler.play_audio("Title Music")
		
	AudioHandler.stop_audio("Inst")
	AudioHandler.stop_audio("Voices")
	AudioHandler.stop_audio("Gameover Music")
	
	# for mod_data in ModLoader.mod_instances:
	# 	for week in ModLoader.mod_instances[mod_data].weeks:
	# 		weeks.append(week)
	
	var file: FileAccess
	
	for week in weeks:
		file = FileAccess.open("res://Assets/Weeks/" + week + ".json", FileAccess.READ)
		
		var test_json_conv = JSON.new()
		test_json_conv.parse(file.get_as_text())
		var data = test_json_conv.get_data()
		
		if "hide_from_story_mode" in data:
			if !data.hide_from_story_mode:
				var new_week = week_template.duplicate()
				new_week.name = week
				
				var sprite = new_week.get_node("Sprite2D")
				sprite.texture = load("res://Assets/Images/UI/Story Mode/Weeks/" + week + ".png")
				
				if sprite.texture == null:
					sprite.texture = load("res://icon.png")
				
				new_week.get_node("Lock").visible = false
				
				if weeks_node.get_child_count() > 1:
					new_week.position.y = weeks_node.get_children()[weeks_node.get_child_count() - 1].position.y + 120
				
				new_week.visible = true
				
				new_week.week_name = week
				
				var songs = []
				
				for song in data.songs:
					if song is Dictionary:
						if song.story:
							songs.append([song.song, song.icon])
					else:
						songs.append([song, "placeholder-icon"])
				
				new_week.songs = songs
				
				if "difficulties" in data:
					new_week.difficulties = data.difficulties
				else:
					new_week.difficulties = ["easy", "normal", "hard"]
				
				if "chars" in data:
					new_week.characters = data.chars
				else:
					new_week.characters = ["dad", "bf", "gf"]
				
				if "week_name" in data:
					new_week.week_text = data.week_name
				else:
					new_week.week_text = ""
				
				if "story_color" in data:
					new_week.color = Color(data.story_color)
				
				if len(songs) > 0:
					weeks_node.add_child(new_week)
				else:
					new_week.queue_free()
	
	weeks_node.remove_child(week_template)
	week_template.free()
	
	update_selection()

func _process(_delta):
	if Input.is_action_just_pressed("ui_back"):
		Scenes.switch_scene("Main Menu")
	
	if Input.is_action_just_pressed("ui_down"):
		update_selection(1)
	if Input.is_action_just_pressed("ui_up"):
		update_selection(-1)
	
	if Input.is_action_just_pressed("ui_left"):
		change_difficulty(-1)
	if Input.is_action_just_pressed("ui_right"):
		change_difficulty(1)
	
	if Input.is_action_pressed("ui_left"):
		left_arrow.play("arrow push")
	else:
		left_arrow.play("arrow")
	if Input.is_action_pressed("ui_right"):
		right_arrow.play("arrow push")
	else:
		right_arrow.play("arrow")
	
	if Input.is_action_just_pressed("ui_accept"):
		Globals.song_name = weeks_node.get_children()[selected].songs[0][0]
		Globals.song_difficulty = difficulties[selected_difficulty].to_lower()
		Globals.freeplay = false
		
		Globals.week_songs = []
		
		for song in weeks_node.get_children()[selected].songs:
			Globals.week_songs.append(song[0])
		
		Globals.week_songs.erase(Globals.song_name)
		
		var file: FileAccess = FileAccess.open(Paths.song_path(Globals.song_name, Globals.song_difficulty), FileAccess.READ)

		if file.get_as_text() != null:
			var test_json_conv = JSON.new()
			test_json_conv.parse(file.get_as_text())
			Globals.song = test_json_conv.get_data()["song"]
			
			Scenes.switch_scene("Gameplay")
			AudioHandler.play_audio("Confirm Sound")

@onready var camera = $Camera2D
@onready var track_text = $"Main UI/Tracks"
@onready var characters = $"Main UI/Characters"

func update_selection(amount = 0):
	selected += amount
	
	if selected < 0:
		selected = weeks_node.get_child_count() - 1
	if selected > weeks_node.get_child_count() - 1:
		selected = 0
	
	AudioHandler.play_audio("Scroll Menu")
	
	var selected_week = weeks_node.get_children()[selected]
	
	# 507 (template value) - 360 (screen height / 2) = 147 (offset of camera)
	camera.position.y = selected_week.global_position.y - 165
	
	for week in weeks_node.get_children():
		if week != selected_week:
			week.modulate.a = 0.6
		else:
			week.modulate.a = 1
	
	track_text.text = "Tracks\n\n"
	
	for song in selected_week.songs:
		track_text.text += song[0].to_upper() + "\n"
	
	if Settings.get_data("story_mode_icons"):
		icon.visible = true
		icon.texture = load("res://Assets/Images/Icons/" + selected_week.songs[0][1] + ".png")
		Globals.detect_icon_frames(icon)
	else:
		icon.visible = false
		icon.texture = null
	
	var dad_load = load("res://Scenes/Story Mode Characters/" + selected_week.characters[0] + ".tscn")
	var bf_load = load("res://Scenes/Story Mode Characters/" + selected_week.characters[1] + ".tscn")
	var gf_load = load("res://Scenes/Story Mode Characters/" + selected_week.characters[2] + ".tscn")
	
	if dad_load != null and dad.name != selected_week.characters[0]:
		dad.queue_free()
	else:
		dad_load = null
	if bf_load != null and bf.name != selected_week.characters[1]:
		bf.queue_free()
	else:
		bf_load = null
	if gf_load != null and gf.name != selected_week.characters[2]:
		gf.queue_free()
	else:
		gf_load = null
	
	var old_dad = dad
	var old_bf = bf
	var old_gf = gf
	
	if dad_load != null:
		dad = dad_load.instantiate()
	if bf_load != null:
		bf = bf_load.instantiate()
	if gf_load != null:
		gf = gf_load.instantiate()
	
	dad.position = old_dad.position
	bf.position = old_bf.position
	gf.position = old_gf.position
	
	if dad_load != null:
		characters.add_child(dad)
	if bf_load != null:
		characters.add_child(bf)
	if gf_load != null:
		characters.add_child(gf)
	
	dad.get_node('AnimatedSprite2D').play('idle')
	bf.get_node('AnimatedSprite2D').play('idle')
	gf.get_node('AnimatedSprite2D').play('idle')
	
	week_name.text = selected_week.week_text
	difficulties = selected_week.difficulties
	bg.color = selected_week.color
	
	change_difficulty()

func change_difficulty(change: int = 0):
	selected_difficulty += change
	
	if selected_difficulty < 0:
		selected_difficulty = len(difficulties) - 1
	if selected_difficulty > len(difficulties) - 1:
		selected_difficulty = 0
	
	var path: String = "res://Assets/Images/UI/Story Mode/Difficulties/%s.png" % difficulties[selected_difficulty].to_lower()
	var texture: Texture2D
	
	if ResourceLoader.exists(path):
		texture = load(path)
	else:
		texture = load("res://icon.png")
	
	difficulty_sprite.texture = texture
	
	if is_instance_valid(tween) and tween.is_valid():
		tween.stop()
	
	difficulty_sprite.position.y = 492
	tween = create_tween()
	tween.tween_property(difficulty_sprite, "position:y", 505, 0.1)
	
	var week_score_data = 0
	
	for song in weeks_node.get_children()[selected].songs:
		week_score_data += Scores.get_song_score(song[0].to_lower(), difficulties[selected_difficulty].to_lower())
	
	week_score.text = "SCORE: " + str(week_score_data)
