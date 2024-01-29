@icon('res://Assets/Images/Godot/Icons/gameplay.svg')
class_name Gameplay extends Node2D


var template_note: Node2D

var template_notes: Dictionary = {}

var stage_string: String = "stage"
var default_camera_zoom: float = 1.05
var default_hud_zoom: float = 1.0

var song_data: Dictionary = {}

var bf: Node2D
var dad: Node2D
var gf: Node2D

var gf_speed: int = 1

var stage: Node2D

var strums: PackedScene

var gameplay_text: Label

var enemy_notes: Node2D
var player_notes: Node2D

var note_data_array: Array = []
var preloaded_notes: Array[Note] = []

@onready var preload_notes: bool = Settings.get_data('preload_notes')
@onready var side_ratings_enabled: bool = Settings.get_data('side_ratings_enabled')

var misses: int = 0
var combo: int = 0
var score: int = 0

var accuracy: float = 0.0
@onready var accuracy_calculator: Node = $AccuracyCalculator

var key_count: int = 4

@onready var camera = $Camera
@onready var ui_layer: CanvasLayer = $UI
@onready var ui: Node2D = ui_layer.get_node('HUD')

@onready var progress_bar: Node2D = ui.get_node('Progress Bar')
@onready var progress_bar_bar: ProgressBar = progress_bar.get_node("ProgressBar")

@onready var accuracy_text: Label = ui.get_node("Ratings/Accuracy Text")

@onready var countdown_node: Node = ui.get_node('Countdown')

@onready var ready_sprite: Sprite2D = countdown_node.get_node("Ready")
@onready var set: Sprite2D = countdown_node.get_node("Set")
@onready var go: Sprite2D = countdown_node.get_node("Go")

var health: float = 1.0
@onready var health_bar: Node2D = ui.get_node('Health Bar')
@onready var health_bar_bg: Sprite2D = health_bar.get_node("Bar/BG")

var player_icon: Sprite2D
var enemy_icon: Sprite2D

var counter: int = -1
var counting: bool = false
var in_cutscene: bool = false

var bpm_changes: Array = []

var strum_texture: SpriteFrames

var ratings: Dictionary = {
	"marvelous": 0,
	"sick": 0,
	"good": 0,
	"bad": 0,
	"shit": 0,
}

var ms_offsync_allowed: float = 50

var player_strums: Node2D
var enemy_strums: Node2D

var events: Array = []
var event_nodes: Dictionary = {}
var events_to_do: Array = []

static var instance: Gameplay

signal spawn_note(note)
signal beat_hit_post

func section_start_time(section: int = 0) -> float:
	var section_position: float = 0.0
	var current_bpm: float = song_data["bpm"]
	
	for i in section:
		if song_data.notes[i].has("changeBPM") and song_data.notes[i]["changeBPM"]: current_bpm = song_data.notes[i]["bpm"]
		section_position += 4.0 * (1000.0 * (60.0 / current_bpm))
	
	return section_position

func _init() -> void:
	instance = self

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	ms_offsync_allowed *= Globals.song_multiplier
	
	Conductor.safeZoneOffset = 166.6 * Globals.song_multiplier
	song_data = Globals.song
	
	bpm_changes = Conductor.map_bpm_changes(song_data)
	
	if song_data.has("keyCount"):
		key_count = int(song_data["keyCount"])
	elif song_data.has("mania"):
		match(int(song_data["mania"])):
			1: key_count = 6
			2: key_count = 7
			3: key_count = 9
	
	song_data["keyCount"] = key_count
	Globals.song["keyCount"] = key_count
	
	Globals.key_count = key_count
	Settings.setup_binds()
	
	strum_texture = load("res://Assets/Images/Notes/default/default.res")
	template_notes["default"] = load("res://Scenes/Gameplay/Note.tscn").instantiate()
	
	strums = load("res://Scenes/Gameplay/Strums/" + str(key_count) + ".tscn")
	
	if not strums:
		printerr("No set of strums for key count of %s found!" % key_count)
		key_count = 4
		Globals.key_count = key_count
		Settings.setup_binds()
		strums = load("res://Scenes/Gameplay/Strums/" + str(key_count) + ".tscn")
	
	AudioHandler.stop_audio("Title Music")
	
	if song_data.has("stage"):
		stage_string = song_data.stage
	
	if song_data.has("ui_Skin"):
		song_data["ui_skin"] = song_data["ui_Skin"]
	if not song_data.has("ui_skin"):
		song_data["ui_skin"] = "default"
	
	var skin_data: Node
	
	# loading new skin
	var skin: String = song_data["ui_skin"]
	
	if not ResourceLoader.exists("res://Scenes/UI Skins/" + skin + ".tscn"):
		printerr("No skin %s found!" % skin)
		skin_data = load("res://Scenes/UI Skins/default.tscn").instantiate()
	else:
		skin_data = load("res://Scenes/UI Skins/" + skin + ".tscn").instantiate()
	
	# applying skin data
	# ratings
	rating_textures = [
		load(skin_data.rating_path + "marvelous.png"),
		load(skin_data.rating_path + "sick.png"),
		load(skin_data.rating_path + "good.png"),
		load(skin_data.rating_path + "bad.png"),
		load(skin_data.rating_path + "shit.png")
	]
	
	ready_sprite.scale = Vector2(skin_data.countdown_scale, skin_data.countdown_scale)
	set.scale = Vector2(skin_data.countdown_scale, skin_data.countdown_scale)
	go.scale = Vector2(skin_data.countdown_scale, skin_data.countdown_scale)
	
	ready_sprite.texture = skin_data.ready_texture
	set.texture = skin_data.set_texture
	go.texture = skin_data.go_texture
	
	cool_rating.scale = Vector2(skin_data.rating_scale, skin_data.rating_scale)
	
	ready_sprite.texture_filter = skin_data.texture_filter
	set.texture_filter = skin_data.texture_filter
	go.texture_filter = skin_data.texture_filter
	cool_rating.texture_filter = skin_data.texture_filter
	
	# numbers
	numbers = []
	for i in 10:
		numbers.append(load(skin_data.numbers_path + "num%s.png" % i))
	
	for child in ratings_thing.get_node("Numbers").get_children():
		child.scale = Vector2(skin_data.number_scale, skin_data.number_scale)
		child.texture_filter = skin_data.texture_filter
	
	# health bar
	health_bar_bg.texture = skin_data.health_bar_texture
	health_bar_bg.texture_filter = skin_data.texture_filter
	
	# notes
	template_notes["default"].get_node("AnimatedSprite2D").frames = skin_data.notes_texture
	template_notes["default"].scale *= Vector2(skin_data.note_scale, skin_data.note_scale)
	template_notes["default"].texture_filter = skin_data.texture_filter
	template_notes["default"].get_node("Line2D").scale = skin_data.note_hold_scale
	template_notes["default"].get_node("Line2D").texture_filter = skin_data.texture_filter
	
	for texture in Note.held_sprites:
		Note.held_sprites[texture] = [
			load(skin_data.held_note_path + "%s hold0000.png" % texture),
			load(skin_data.held_note_path + "%s hold end0000.png" % texture)
		]
	
	strum_texture = skin_data.strums_texture
	
	var gf_name: String = "gf"
	
	if "gf" in song_data:
		gf_name = song_data["gf"]
	elif "gfVersion" in song_data:
		gf_name = song_data["gfVersion"]
	elif "player3" in song_data:
		gf_name = song_data["player3"]
	
	song_data["gf"] = gf_name

	if not Settings.get_data("ultra_performance"):
		stage = Globals.load_stage(stage_string, "stage").instantiate()
	else:
		stage = Globals.load_stage("", "").instantiate()
	
	camera.zoom = Vector2(stage.camera_zoom, stage.camera_zoom)
	default_camera_zoom = stage.camera_zoom
	
	player_icon = health_bar.get_node("Player")
	enemy_icon = health_bar.get_node("Opponent")
	
	if not Settings.get_data("ultra_performance"):
		# characters
		player_point = stage.get_node("Player Point")
		dad_point = stage.get_node("Dad Point")
		gf_point = stage.get_node("GF Point")
		
		bf = Globals.load_character(song_data["player1"], 'bf').instantiate()
		bf.position = player_point.position
		bf.scale.x *= -1.0
		
		dad = Globals.load_character(song_data["player2"], 'dad').instantiate()
		dad.position = dad_point.position
		
		gf = Globals.load_character(gf_name, 'gf').instantiate()
		gf.position = gf_point.position
		
		add_child(stage)
		
		add_child(gf)
		add_child(bf)
		
		if not song_data["player2"]:
			remove_child(dad)
			dad.queue_free()
			dad = gf
		else:
			add_child(dad)
		
		# health bar coloring
		var health_bar_bar: ProgressBar = health_bar.get_node("Bar/ProgressBar")
		health_bar_bar.get("theme_override_styles/fill").bg_color = bf.health_bar_color
		health_bar_bar.get("theme_override_styles/background").bg_color = dad.health_bar_color
		
		# icons
		player_icon.texture = bf.health_icon
		enemy_icon.texture = dad.health_icon
		
		Globals.detect_icon_frames(player_icon)
		Globals.detect_icon_frames(enemy_icon)
		
		# camera movement
		camera.position_smoothing_enabled = false
		
		if song_data["notes"][0]["mustHitSection"]:
			camera.position = stage.get_node("Player Point").position + (bf.camOffset * Vector2(-1, 1)) + cam_offset + stage.player_camera_offset
		else:
			camera.position = stage.get_node("Dad Point").position + dad.camOffset + cam_offset + stage.opponent_camera_offset
	
	# note spawning / conversion
	for section in song_data["notes"]:
		for note in section["sectionNotes"]:
			if note[1] != -1:
				if note.size() == 3: note.push_back(0)
				var type: String = "default"
				
				if note[3] is Array: note[3] = note[3][0]
				elif note[3] is String:
					type = note[3]
					
					note[3] = 0
					note.push_back(type)
				
				if note.size() == 4: note.push_back("default")
				
				if note[4] is String:
					type = note[4]
					
					if not template_notes.has(type):
						var loaded_note: PackedScene = load("res://Scenes/Gameplay/Note Types/" + type + ".tscn")
						
						if loaded_note: template_notes[type] = loaded_note.instantiate()
						else: template_notes[type] = template_notes["default"]
				
				if not section.has("altAnim"):
					section["altAnim"] = false
				if not note[3]:
					note[3] = 0
				
				note_data_array.push_back([float(note[0]) + Settings.get_data("offset") + (AudioServer.get_output_latency() * 1000), note[1], note[2], bool(section["mustHitSection"]), int(note[3]), type, bool(section["altAnim"])])
			elif note.size() >= 5:
				events_to_do.append([note[2], float(note[0]), note[3], note[4]])
	
	note_data_array.sort_custom(note_sort)
	
	inst.stream = null
	inst.stream = Globals.load_song_audio('Inst')
	inst.pitch_scale = Globals.song_multiplier
	inst.volume_db = 0
	
	if song_data["needsVoices"]:
		voices.stream = null
		voices.stream = Globals.load_song_audio('Voices')
		voices.pitch_scale = Globals.song_multiplier
		voices.volume_db = 0
	
	if not Settings.get_data("custom_scroll_bool"):
		Globals.scroll_speed = float(song_data["speed"])
	else:
		Globals.scroll_speed = Settings.get_data("custom_scroll")
	
	Globals.scroll_speed /= Globals.song_multiplier
	
	Conductor.songPosition = 0.0
	Conductor.curBeat = 0
	Conductor.curStep = 0
	Conductor.change_bpm(float(song_data["bpm"]), bpm_changes)
	Conductor.connect("beat_hit", Callable(self, "beat_hit"))
	
	gameplay_text = ui.get_node("Gameplay Text/Gameplay Text")
	
	player_notes = ui.get_node("Player Notes")
	enemy_notes = ui.get_node("Enemy Notes")
	
	player_strums = strums.instantiate()
	player_strums.name = "Player Strums"
	player_strums.is_player = true
	player_strums.position.x = 800
	
	enemy_strums = strums.instantiate()
	enemy_strums.name = "Enemy Strums"
	enemy_strums.is_player = false
	enemy_strums.position.x = 150
	
	for strum in player_strums.get_children():
		strum.get_node("AnimatedSprite2D").frames = strum_texture
		strum.scale *= Vector2(skin_data.strum_scale, skin_data.strum_scale)
		strum.texture_filter = skin_data.texture_filter
	
	for strum in enemy_strums.get_children():
		strum.get_node("AnimatedSprite2D").frames = strum_texture
		strum.enemy_strum = true
		strum.scale *= Vector2(skin_data.strum_scale, skin_data.strum_scale)
		strum.texture_filter = skin_data.texture_filter
	
	ui.add_child(player_strums)
	ui.add_child(enemy_strums)
	
	if Settings.get_data("downscroll"):
		player_strums.position.y = 620
		enemy_strums.position.y = 620
		gameplay_text.position.y = 115
		health_bar.position.y = 64
		progress_bar.position.y = 698
	else:
		player_strums.position.y = 100
		enemy_strums.position.y = 100
		gameplay_text.position.y = 682
		health_bar.position.y = 623
		progress_bar.position.y = 6
	
	if Settings.get_data("middlescroll"):
		player_strums.position.x = 470
		enemy_strums.visible = false
		enemy_strums.process_mode = PROCESS_MODE_PAUSABLE
		enemy_notes.visible = false
		enemy_notes.process_mode = PROCESS_MODE_PAUSABLE
	
	player_notes.position.x = player_strums.position.x
	enemy_notes.position.x = enemy_strums.position.x
	
	player_notes.scale = player_strums.scale
	enemy_notes.scale = enemy_strums.scale
	
	progress_bar.visible = Settings.get_data('progress_bar_enabled')
	
	Conductor.songPosition = (Conductor.timeBetweenBeats * -4.0) * Globals.song_multiplier
	update_gameplay_text()
	
	var freeplay_song_data: bool = false
	if song_data.has("cutscene_in_freeplay"): freeplay_song_data = song_data.cutscene_in_freeplay
	
	if Settings.get_data("freeplay_cutscenes"): freeplay_song_data = true
	
	if (!Globals.freeplay or freeplay_song_data) and Globals.do_cutscenes and not Settings.get_data("ultra_performance"):
		if song_data.has("cutscene") and ResourceLoader.exists("res://Scenes/Cutscenes/" + song_data["cutscene"] + ".tscn"):
			camera.position_smoothing_enabled = true
			
			var cutscene: Cutscene = load("res://Scenes/Cutscenes/" + song_data["cutscene"] + ".tscn").instantiate()
			add_child(cutscene)
			
			cutscene.connect("finished", Callable(self, "start_countdown"))
			in_cutscene = true
		else:
			start_countdown()
	else:
		start_countdown()
	
	update_progress_bar_color(song_data["notes"][0]["mustHitSection"])
	
	if song_data.has("events"):
		for event in song_data.events: events_to_do.append(event)
	
	var event_file: FileAccess
	
	if not Settings.get_data("ultra_performance"):
		event_file = FileAccess.open(Paths.base_song_path(Globals.song_name) + "events.json", FileAccess.READ)
		
		if FileAccess.file_exists(Paths.base_song_path(Globals.song_name) + "events.json"):
			var test_json_conv = JSON.new()
			test_json_conv.parse(event_file.get_as_text())
			var event_data = test_json_conv.get_data().song
			
			if "events" in event_data or "notes" in event_data:
				if "events" in event_data:
					for event in event_data.events: events_to_do.append(event)
				
				if "notes" in event_data:
					for section in event_data.notes:
						for note in section.sectionNotes:
							if note[1] == -1: events_to_do.append([note[2], float(note[0]), note[3], note[4]])
				
		for event in events_to_do:
			# is psych event lmao
			if (event[0] is float or event[0] is int) and event[1] is Array:
				for psych_event in event[1]: events.append([psych_event[0], event[0], psych_event[1], psych_event[2]])
			else: events.append(event)
			
			var event_name: String = events[len(events) - 1][0]
			
			if !event_nodes.has(event_name) and FileAccess.file_exists("res://Scenes/Events/" + event_name.to_lower() + ".tscn"):
				event_nodes[event_name] = load("res://Scenes/Events/" + event_name.to_lower() + ".tscn").instantiate()
				add_child(event_nodes[event_name])
	
	events.sort_custom(event_sort)
	
	for event in events:
		if event_nodes.has(event[0]):
			Globals.emit_signal("event_setup", event)
			event_nodes[event[0]].setup_event(event[2], event[3])
	
	var modcharts: DirAccess = DirAccess.open(Paths.base_song_path(Globals.song_name))
	modcharts.list_dir_begin() # TODOConverter3To4 fill missing arguments https://github.com/godotengine/godot/pull/40547
	
	while true:
		var file = modcharts.get_next()
		
		if file == "":
			break
		elif !file.begins_with(".") and file.ends_with(".tscn"):
			var scene = load(Paths.base_song_path(Globals.song_name) + file)
			
			if is_instance_valid(scene):
				var modchart = scene.instantiate()
				add_child(modchart)
	
	if preload_notes:
		for note in note_data_array:
			var is_player_note: bool = true
			
			if note[3] and int(note[1]) % (key_count * 2) >= key_count:
				is_player_note = false
			elif !note[3] and int(note[1]) % (key_count * 2) <= key_count - 1:
				is_player_note = false
			
			var new_note: Note = template_notes[note[5]].duplicate()
			new_note.strum_time = note[0]
			new_note.note_data = int(note[1]) % key_count
			new_note.direction = player_strums.get_child(new_note.note_data).direction
			new_note.visible = true
			new_note.play_animation("")
			new_note.strum_y = player_strums.get_child(new_note.note_data).global_position.y
			
			new_note.is_alt = note[6]
			
			if note.size() >= 5:
				new_note.character = note[4]
			
			if float(note[2]) >= Conductor.timeBetweenSteps:
				new_note.is_sustain = true
				new_note.sustain_length = float(note[2])
				new_note.set_held_note_sprites()
				new_note.get_node("Line2D").texture = new_note.held_sprites[Globals.dir_to_animstr(new_note.direction)][0]
			
			new_note.is_player = is_player_note
			new_note.position.y = -5000.0
			
			# note_data_array.remove_at(note_data_array.find(note))
			preloaded_notes.push_back(new_note)
		
		preloaded_notes.sort_custom(preloaded_sort)
	
	rating_text.visible = side_ratings_enabled
	Globals.emit_signal('_ready_post')

@onready var inst = AudioHandler.get_node("Inst")
@onready var voices = AudioHandler.get_node("Voices")

@onready var threaded_note_loading: bool = Settings.get_data('threaded_note_spawning')
var threaded_note_timer: Timer

func _physics_process(_delta: float) -> void:
	var inst_pos: float = (inst.get_playback_position() + AudioServer.get_time_since_last_mix()) * 1000.0
	
	if abs(inst_pos - Conductor.songPosition) > ms_offsync_allowed:
		inst.seek(Conductor.songPosition / 1000.0)
		voices.seek(Conductor.songPosition / 1000.0)
	
	if voices.stream and inst.get_playback_position() * 1000.0 > voices.stream.get_length() * 1000.0:
		voices.volume_db = -80.0
	
	if not threaded_note_loading:
		load_potential_notes()
	else:
		call_deferred_thread_group('load_potential_notes')
	
	for event in events:
		if Conductor.songPosition >= event[1]:
			if event_nodes.has(event[0]):
				Globals.emit_signal("event_processed", event)
				event_nodes[event[0]].process_event(event[2], event[3])
			
			events.erase(event)
		else:
			break

var can_leave_game:bool = true

@onready var bot = Settings.get_data("bot")
@onready var miss_sounds = Settings.get_data("miss_sounds")

var camera_zooming: bool = false

var lerp_hud_offset: bool = false

func position_hud(delta: float = 0.0) -> void:
	if lerp_hud_offset:
		ui_layer.offset = lerp(ui_layer.offset, Vector2(-640.0 * (ui_layer.scale.x - 1), -360.0 * (ui_layer.scale.y - 1)), delta * 4.0)
	else:
		ui_layer.offset = Vector2(-640.0 * (ui_layer.scale.x - 1), -360.0 * (ui_layer.scale.y - 1))

func _process(delta: float) -> void:
	if camera_zooming:
		camera.zoom = Vector2(
			Globals.glerp(camera.zoom.x, default_camera_zoom, 0.05, delta),
			Globals.glerp(camera.zoom.y, default_camera_zoom, 0.05, delta)
		)
	
		if camera.zoom.x > 1.35:
			camera.zoom = Vector2(1.35, 1.35)
		
		ui_layer.scale = Vector2(Globals.glerp(ui_layer.scale.x, default_hud_zoom, 0.05, delta),
				Globals.glerp(ui_layer.scale.y, default_hud_zoom, 0.05, delta))
		position_hud(delta)
	
	if not in_cutscene:
		Conductor.songPosition += (delta * 1000.0) * Globals.song_multiplier
	if Input.is_action_just_pressed("restart_song"):
		Scenes.switch_scene("Gameplay")
	
	if counting:
		var prev_counter: int = counter
		
		if Conductor.curBeat >= 0:
			counter = 4
		# increment counter every beat basically (used to be -4.0 + counter but that no work ig so ae)
		elif Conductor.curBeat >= -3.0 + counter:
			counter += 1
		
		if prev_counter != counter:
			var tween: Tween
			
			if counter > 0 and counter < 4:
				tween = create_tween().set_trans(Tween.TRANS_QUAD)
			
			ready_sprite.visible = false
			set.visible = false
			go.visible = false
			
			beat_hit(true)
			
			match(counter):
				0:
					AudioHandler.play_audio("Countdown/3")
				1:
					AudioHandler.play_audio("Countdown/2")
					tween.tween_property(ready_sprite, "modulate", Color.TRANSPARENT, Conductor.timeBetweenBeats * 0.001)
					ready_sprite.visible = true
				2:
					AudioHandler.play_audio("Countdown/1")
					tween.tween_property(set, "modulate", Color.TRANSPARENT, Conductor.timeBetweenBeats * 0.001)
					set.visible = true
				3:
					AudioHandler.play_audio("Countdown/Go")
					tween.tween_property(go, "modulate", Color.TRANSPARENT, Conductor.timeBetweenBeats * 0.001)
					go.visible = true
				4:
					AudioHandler.play_audio("Inst")
					
					if song_data["needsVoices"]:
						AudioHandler.play_audio("Voices")
						voices.seek(0)
					
					inst.seek(0) # cool syncing stuff
					
					counting = false
					in_cutscene = false
					
					countdown_node.queue_free()
					Conductor.songPosition = 0.0
	
	if OS.is_debug_build() and Input.is_action_just_pressed('skip_song'):
		Conductor.songPosition = inst.stream.get_length() * 1000.0 + 5.0
		can_leave_game = true
	
	if Conductor.songPosition > inst.stream.get_length() * 1000.0 and can_leave_game:
		can_leave_game = false
		
		voices.volume_db = -80.0
		inst.volume_db = -80.0
		
		# prevents some bs progess bar issues lol
		progress_bar.visible = false
		
		if Globals.song_multiplier >= 1.0 and not Settings.get_data("bot"):
			if Scores.get_song_score(Globals.song_name.to_lower(), Globals.song_difficulty.to_lower()) < score:
				Scores.set_song_score(Globals.song_name.to_lower(), Globals.song_difficulty.to_lower(), score)
		
		if Globals.freeplay:
			Scenes.switch_scene("Freeplay")
		else:
			if len(Globals.week_songs) < 1:
				Scenes.switch_scene("Story Mode")
			else:
				Globals.song_name = Globals.week_songs[0]
				
				var file := FileAccess.open(Paths.song_path(Globals.song_name, Globals.song_difficulty), FileAccess.READ)
				
				var test_json_conv = JSON.new()
				test_json_conv.parse(file.get_as_text())
				Globals.song = test_json_conv.get_data()["song"]
				
				Globals.week_songs.erase(Globals.week_songs[0])
				
				Scenes.switch_scene("Gameplay", true)
	
	if Input.is_action_just_pressed("ui_back"):
		if Globals.freeplay:
			Scenes.switch_scene("Freeplay")
		else:
			Scenes.switch_scene("Story Mode")
	
	if Input.is_action_just_pressed("charting_menu") and Settings.get_data("debug_menus") and not in_cutscene:
		Scenes.switch_scene("Charter")
	
	for note in enemy_notes.get_children():
		if note.strum_time > Conductor.songPosition:
			continue
		
		if note.should_hit and !note.being_pressed:
			var strum = note.strum
			
			if not is_instance_valid(strum):
				continue
			
			if dad and dad.play_singing_animations and note.play_hit_animations:
				if note.is_alt and dad.has_anim("sing" + Globals.dir_to_animstr(note.direction).to_upper() + "-alt", note.character):
					if note.character != 0:
						dad.play_animation("sing" + Globals.dir_to_animstr(note.direction).to_upper() + "-alt", true, note.character)
					else:
						dad.play_animation("sing" + Globals.dir_to_animstr(note.direction).to_upper() + "-alt", true)
				else:
					if note.character != 0:
						dad.play_animation("sing" + Globals.dir_to_animstr(note.direction).to_upper(), true, note.character)
					else:
						dad.play_animation("sing" + Globals.dir_to_animstr(note.direction).to_upper(), true)
				
				dad.timer = 0
			
			if note.opponent_note_glow:
				strum.play_animation("static")
				strum.play_animation("confirm")
			
			Globals.emit_signal("enemy_note_hit", note, note.note_data, note.name, note.character)
			Globals.emit_signal("note_hit", note, note.note_data, note.name, note.character, false)
			
			note.note_hit()
			
			if note.is_sustain:
				note.being_pressed = true
			
			camera_zooming = true
		
		if !note.is_sustain or ("should_hit" in note and !note.should_hit):
			note.queue_free()
	
	if !bot:
		for note in player_notes.get_children():
			# skip this one
			if Conductor.songPosition < note.strum_time + Conductor.safeZoneOffset:
				continue
			
			if !note.being_pressed:
				if note.should_hit and !note.cant_miss:
					if bf and note.play_hit_animations:
						if note.character != 0:
							bf.play_animation("sing" + Globals.dir_to_animstr(note.direction).to_upper() + "miss", true, note.character)
						else:
							bf.play_animation("sing" + Globals.dir_to_animstr(note.direction).to_upper() + "miss", true)
						
						bf.timer = 0
					
					misses += 1
					score -= 10
					total_notes += 1
					
					# -2.25 & -2.75 for etterna mode
					if note.is_sustain and note.sustain_length != note.og_sustain_length: total_hit += -0.25
					else: total_hit += -0.75
					
					health -= note.miss_damage
					
					if combo >= 10 and gf: gf.play_animation("sad", true)
					combo = 0
					
					accuracy_calculator.record_hit(Conductor.safeZoneOffset)
					update_gameplay_text()
					
					if miss_sounds: AudioHandler.play_audio("Misses/" + str(round(randf_range(1,3))))
					
					Globals.emit_signal("note_miss", note, note.note_data, note.name, note.character)
					note.note_miss()
				elif note.cant_miss:
					Globals.emit_signal("note_miss", note, note.note_data, note.name, note.character)
				
				note.queue_free()

var curSection: int = 0

var cam_locked: bool = false
var cam_offset: Vector2 = Vector2()

@onready var player_point: Node2D
@onready var dad_point: Node2D
@onready var gf_point: Node2D

func beat_hit(dumb = false):
	if camera_zooming:
		if not counting:
			if Conductor.curBeat % 4 == 0 and Settings.get_data("cameraZooms"):
				camera.zoom += Vector2(0.015, 0.015)
				ui_layer.scale += Vector2(0.02, 0.02)
				position_hud()
	
	var prevSection = curSection
	
	curSection = floor(Conductor.curStep / 16)
	
	var is_alt:bool = false
	
	if curSection != prevSection and !cam_locked:
		if len(song_data["notes"]) - 1 >= curSection:
			if "altAnim" in song_data["notes"][curSection]:
				is_alt = song_data["notes"][curSection]["altAnim"]
	
	if not dumb:
		if bf:
			if bf.is_dancing():
				if "anim_player" in bf:
					bf.dance(null, is_alt)
				else:
					bf.dance()
		if dad:
			if dad.is_dancing() and dad != gf:
				if "anim_player" in dad:
					dad.dance(null, is_alt)
				else:
					dad.dance()
		if gf:
			if gf.is_dancing() and Conductor.curBeat % gf_speed == 0:
				if "anim_player" in gf:
					gf.dance(null, is_alt)
				else:
					gf.dance()
	
	if curSection >= 0 and curSection != prevSection and !cam_locked:
		if len(song_data["notes"]) - 1 >= curSection:
			if bf and dad:
				camera.position_smoothing_enabled = true
				
				if song_data["notes"][curSection]["mustHitSection"]:
					camera.position = player_point.position + (bf.camOffset * Vector2(-1, 1)) + cam_offset + stage.player_camera_offset
					update_progress_bar_color(false)
					Globals.emit_signal('camera_moved', 'bf')
				else:
					camera.position = dad_point.position + dad.camOffset + cam_offset + stage.opponent_camera_offset
					update_progress_bar_color(true)
					Globals.emit_signal('camera_moved', 'dad')
	
	if Globals.song:
		if "song" in Globals.song:
			var time_left = str(int(inst.stream.get_length() - inst.get_playback_position()))
	
	beat_hit_post.emit()

func update_progress_bar_color(opponent: bool) -> void:
	if (not dad) or (not bf):
		return
	if opponent:
		var tween: Tween = create_tween()
		tween.tween_property(progress_bar_bar, 'modulate', dad.health_bar_color, Conductor.timeBetweenBeats / 1000.0)
	else:
		var tween: Tween = create_tween()
		tween.tween_property(progress_bar_bar, 'modulate', bf.health_bar_color, Conductor.timeBetweenBeats / 1000.0)

# loosely based on kade's etterna shit i think
const wife_conditions: Array = [
	[99.9935, 'AAAAA'],
	[99.955, 'AAAA'],
	[99.70, 'AAA'],
	[93.0, 'AA'],
	[80.0, 'A'],
	[70.0, 'B'],
	[60.0, 'C'],
	[50.0, 'D'],
	[-INF, 'F'],
]

@onready var status_mode: String = Settings.get_data('status_text_mode')

func update_gameplay_text() -> void:
	# if total_hit != 0 and total_notes != 0:
		# accuracy = clamp((total_hit / total_notes) * 100.0, 0.0, INF)
	# else:
	#	accuracy = 0.0
	accuracy = accuracy_calculator.get_accuracy() * 100.0
	
	var rating_string: String = 'BOT' if bot else \
			return_score_rating_string()
	
	match status_mode:
		'none':
			gameplay_text.text = ''
		'sc mis':
			gameplay_text.text = '<  Score:%s ~ Misses:%s  >' % [score, misses]
		'ac rank':
			gameplay_text.text = '<  Accuracy:%s%s ~ %s  >' % [Globals.format_float(accuracy, 3), '%', rating_string]
		'rating':
			gameplay_text.text = '<  %s  >' % rating_string
		'accuracy':
			gameplay_text.text = '<  Accuracy:%s%s  >' % [Globals.format_float(accuracy, 3), '%']
		'misses':
			gameplay_text.text = '<  Misses:%s  >' % misses
		'score':
			gameplay_text.text = '<  Score:%s  >' % score
		'classic':
			gameplay_text.text = '<  Score:%s ~ Misses:%s ~ Accuracy:%s%s ~ %s  >' % [score, misses,
					Globals.format_float(accuracy, 3), '%', rating_string]
		_:
			gameplay_text.text = '<  Accuracy:%s%s ~ Misses:%s ~ %s  >' % [Globals.format_float(accuracy, 3), '%',
					misses, rating_string]

func return_score_rating_string() -> String:
	var rating: String = '???'
	
	for condition in wife_conditions:
		if accuracy > condition[0]:
			rating = condition[1]
			break
	
	var rating_string: String = 'Rating:%s' % rating
	
	if misses == 0:
		var combo_conditions: Array = [
			[ratings.marvelous > 0, 'MFC'],
			[ratings.sick > 0, 'SFC'],
			[ratings.good > 0, 'GFC'],
			[ratings.bad > 0 or ratings.shit > 0, 'FC'],
		]
		
		var combo_rating: String = ""
		
		for condition in combo_conditions:
			if condition[0]:
				combo_rating = ' [%s]' % condition[1]
		
		rating_string += combo_rating
	elif misses < 10:
		rating_string += ' [SDCB]'
	
	return rating_string

var rating_textures: Array = [
	load("res://Assets/Images/UI/Ratings/marvelous.png"),
	load("res://Assets/Images/UI/Ratings/sick.png"),
	load("res://Assets/Images/UI/Ratings/good.png"),
	load("res://Assets/Images/UI/Ratings/bad.png"),
	load("res://Assets/Images/UI/Ratings/shit.png")
]

var numbers: Array = [
	load("res://Assets/Images/UI/Ratings/num0.png"),
	load("res://Assets/Images/UI/Ratings/num1.png"),
	load("res://Assets/Images/UI/Ratings/num2.png"),
	load("res://Assets/Images/UI/Ratings/num3.png"),
	load("res://Assets/Images/UI/Ratings/num4.png"),
	load("res://Assets/Images/UI/Ratings/num5.png"),
	load("res://Assets/Images/UI/Ratings/num6.png"),
	load("res://Assets/Images/UI/Ratings/num7.png"),
	load("res://Assets/Images/UI/Ratings/num8.png"),
	load("res://Assets/Images/UI/Ratings/num9.png")
]

var total_notes: int = 0
var total_hit: float = 0.0

@onready var ratings_thing: Node2D = ui.get_node("Ratings")
@onready var numbers_obj: Node2D = ratings_thing.get_node("Numbers")
@onready var cool_rating: Sprite2D = ratings_thing.get_node("Rating")

var rating_tween: Tween

# etterna judge 4 (old was LE haxe timings)
const timings: Array = [22.5, 45.0, 90.0, 135.0] # [25.0, 50.0, 70.0, 100.0]
const scores: Array = [400.0, 350.0, 200.0, 50.0, -150.0]

func popup_rating(strum_time: float) -> void:
	var ms_dif: float = (Conductor.songPosition - strum_time) / Globals.song_multiplier
	var rating: int = 4
	
	for i in timings.size():
		if abs(ms_dif) <= timings[i]:
			rating = i
			break
	
	if bot:
		rating = 0
		ms_dif = 0.0
	
	var combo_str: String = str(combo).pad_zeros(3)
	
	var i: int = 0
	
	for number in numbers_obj.get_children():
		number.visible = false if i > len(combo_str) - 1 else true
		
		if number.visible:
			number.texture = numbers[int(combo_str[i])]
		
		i += 1
	
	ratings_thing.visible = true
	numbers_obj.position.x = -42 + (-19 * (len(combo_str) - 1))
	cool_rating.texture = rating_textures[rating]
	
	if is_instance_valid(rating_tween) and rating_tween.is_valid():
		rating_tween.kill()
	
	ratings_thing.modulate = Color.WHITE
	ratings_thing.scale = Vector2(1.1, 1.1)
	
	rating_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_parallel()
	rating_tween.tween_property(ratings_thing, 'modulate', Color.TRANSPARENT, 0.2).set_delay(Conductor.timeBetweenBeats * 0.001)
	rating_tween.tween_property(ratings_thing, 'scale', Vector2(1.0, 1.0), 0.1)
	
	score += scores[rating]
	accuracy_text.text = '%s ms%s' % [Globals.format_float(ms_dif, 2), ' (BOT)' if bot else '']
	
	if ms_dif >= 0:
		accuracy_text.set("theme_override_colors/font_color", Color(0.0, 1.0, 1.0))
	else:
		accuracy_text.set("theme_override_colors/font_color", Color(1.0, 0.63, 0.0))
	
	match(rating):
		0, 1:
			if rating == 0:
				# if abs(ms_dif) <= 5:
				# 	total_hit += 1
				# else: 
				# 	total_hit += 0.999
				
				health += 0.035
				ratings.marvelous += 1
			else:
				# total_hit += 0.95
				health += 0.02
				ratings.sick += 1
		2:
			health += 0.01
			# total_hit += 0.85
			ratings.good += 1
		3:
			health -= 0.05
			# total_hit += 0.4
			ratings.bad += 1
		4:
			health -= 0.125
			# total_hit += -0.35
			ratings.shit += 1
	
	accuracy_calculator.record_hit(ms_dif)
	
	update_gameplay_text()
	update_rating_text()

@onready var rating_text: Label = ui.get_node('Gameplay Text/Ratings')

func update_rating_text() -> void:
	if not side_ratings_enabled:
		return
	
	var ma: float = 0.0
	var pa: float = 0.0
	
	var total: float = ratings.sick + ratings.good + ratings.bad + ratings.shit
	var without_sick: float = ratings.good + ratings.bad + ratings.shit
	
	if total != 0 and ratings.marvelous != 0:
		ma = Globals.format_float(ratings.marvelous / total, 2)
	
	if without_sick != 0 and (ratings.marvelous != 0 or ratings.sick != 0):
		pa = Globals.format_float((ratings.marvelous + ratings.sick) / total, 2)
	
	rating_text.text = """ Marvelous: %s
	 Sick: %s
	 Good: %s
	 Bad: %s
	 Shit: %s
	 MA: %s
	 PA: %s""" % [ratings.marvelous, ratings.sick, ratings.good, ratings.bad,\
			ratings.shit, ma, pa]

func start_countdown() -> void:
	counting = true
	in_cutscene = false
	Scenes.current_scene = "Gameplay"

# sorting
func note_sort(a: Array, b: Array) -> bool:
	return a[0] < b[0]
func event_sort(a: Array, b: Array) -> bool:
	return a[1] < b[1]
func preloaded_sort(a: Note, b: Note) -> bool:
	return a.strum_time < b.strum_time

var stupid_preload_index_thing: int = 0

func load_potential_notes() -> void:
	if preloaded_notes.size() > 0:
		while preloaded_notes.size() >= stupid_preload_index_thing + 1 and preloaded_notes[stupid_preload_index_thing].strum_time < Conductor.songPosition + (2500.0 * Globals.song_multiplier):
			var note: Note = preloaded_notes[stupid_preload_index_thing]
			
			if note.is_player:
				player_notes.add_child(note)
			else:
				enemy_notes.add_child(note)
			
			# preloaded_notes.remove_at(preloaded_notes.find(note))
			spawn_note.emit(note)
			stupid_preload_index_thing += 1
		
		return
	
	for note in note_data_array:
		if float(note[0]) > Conductor.songPosition + (2500.0 * Globals.song_multiplier):
			break
		
		var is_player_note: bool = true
		
		if note[3] and int(note[1]) % (key_count * 2) >= key_count:
			is_player_note = false
		elif !note[3] and int(note[1]) % (key_count * 2) <= key_count - 1:
			is_player_note = false
		
		var should_spawn: bool = true
		
		if Settings.get_data("ultra_performance") and !is_player_note and Settings.get_data("middlescroll"):
			should_spawn = false
			note_data_array.remove_at(note_data_array.find(note))
		
		if should_spawn:
			var new_note = template_notes.get(note[5]).duplicate()
			new_note.strum_time = float(note[0])
			new_note.note_data = int(note[1]) % key_count
			new_note.direction = player_strums.get_child(new_note.note_data).direction
			new_note.visible = true
			new_note.play_animation("")
			new_note.strum_y = player_strums.get_child(new_note.note_data).global_position.y
			new_note.is_alt = note[6]
			
			if int(note[4]):
				new_note.character = note[4]
			
			if float(note[2]) >= Conductor.timeBetweenSteps:
				new_note.is_sustain = true
				new_note.sustain_length = float(note[2])
				new_note.set_held_note_sprites()
				new_note.get_node("Line2D").texture = new_note.held_sprites[new_note.direction][0]
				
			if is_player_note:
				new_note.position.x = player_strums.get_child(new_note.note_data).position.x
				player_notes.add_child(new_note)
			else:
				new_note.position.x = player_strums.get_child(new_note.note_data).position.x
				enemy_notes.add_child(new_note)
			
			new_note.is_player = is_player_note
			new_note.position.y = -5000
			
			note_data_array.remove_at(note_data_array.find(note))
			spawn_note.emit(new_note)
		else:
			break


func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return
	
	if Input.is_action_just_pressed('ui_confirm') and not in_cutscene:
		PauseMenu.open()


# fix memory leak cuz i guess this doesn't happen automatically
# /shrug
func _exit_tree() -> void:
	for note in preloaded_notes:
		if not is_instance_valid(note):
			continue
		
		note.free()
	
	preloaded_notes.clear()
