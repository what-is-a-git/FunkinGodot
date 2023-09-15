@icon('res://Assets/Images/Godot/Icons/freeplay_handler.svg')
class_name FreeplayHandler extends Node2D

static var selected: int = 0
var selected_song: bool = false
var cur_icon: Sprite2D

var songs: Array = []
var song_nodes: Array[FreeplaySong] = []

var difficulties: Array = [
	'easy',
	'normal',
	'hard'
]

static var selected_difficulty: int = 1

@onready var tween: Tween
@onready var bg: Sprite2D = $BG
@onready var songs_node: Node2D = $Songs
@onready var template: FreeplaySong = songs_node.get_node('Template')

@onready var inst: AudioStreamPlayer = AudioHandler.get_node('Inst')

func _ready() -> void:
	# read the funny directory
	var weeks: Array = [
		'week0',
		'week1',
		'week2',
		'week3',
		'week4',
		'week5',
		'week6',
		'week7',
		'weekTest',
	]
	
	var ind: int = 0
	var index: int = 0
	
	# make freeplay songs
	songs_node.remove_child(template)
	
	for week in weeks:
		var week_file := FileAccess.open('res://Assets/Weeks/%s.json' % week, FileAccess.READ)
		
		var test_json_conv = JSON.new()
		test_json_conv.parse(week_file.get_as_text())
		var week_songs: Array = test_json_conv.get_data()['songs']
		
		for song_data in week_songs:
			var is_legacy_song_data: bool = song_data is String
			
			var song: String = ''
			
			if is_legacy_song_data:
				song = song_data
			else:
				song = song_data.song
			
			var new_song: FreeplaySong = template.duplicate()
			new_song.visible = true
			new_song.text = song.to_upper()
			new_song.name = song.to_lower() + '_' + str(index)
			new_song.size = Vector2.ZERO
			
			if not is_legacy_song_data:
				var cool_color: String = song_data.color
				new_song.freeplay_color = Color(cool_color)
				
				if 'ignore_difficulties' in song_data:
					new_song.ignore_difficulties = song_data.ignore_difficulties
			
			songs_node.add_child(new_song)
			song_nodes.push_back(new_song)
			
			var icon: Sprite2D = new_song.get_node('Icon')
			icon.global_position.x = new_song.position.x + new_song.size.x + 100.0
			
			if is_legacy_song_data:
				icon.texture = null
				icon.visible = false
			else:
				icon.texture = load('res://Assets/Images/Icons/%s.png' % song_data.icon)
				Globals.detect_icon_frames(icon)
			
			index += 1
			songs.append(song)
		
		week_file.close()
		ind += 1
	
	# stop voices and inst if they playing
	AudioHandler.stop_audio('Inst')
	AudioHandler.stop_audio('Voices')
	AudioHandler.stop_audio('Gameover Music')
	
	# play the cool title music
	if (not AudioHandler.get_node('Title Music').playing) and not Settings.get_data('freeplay_music'):
		AudioHandler.play_audio('Title Music')
	
	Conductor.change_bpm(102)
	
	_change_item()
	bg.modulate = songs_node.get_child(selected).freeplay_color
	
	Conductor.connect('beat_hit', Callable(self, 'beat_hit'))

@onready var dif_text: Label = $Difficulty
@onready var dif_bg: ColorRect = $'Difficulty Background'

var multi_timer: float = 0
var score: int = 0
var cur_score: int = 0
var lerping_score: float = 0.0

func _process(delta: float) -> void:
	lerping_score = clamp(Globals.glerp(lerping_score, score, 0.4, delta), 0.0, INF)
	cur_score = int(lerping_score)
	
	if not difficulties.is_empty():
		dif_text.text = 'PB: %d (%.2fx)\n< %s >' % [cur_score, Globals.song_multiplier,
				difficulties[selected_difficulty].to_upper()]
	
	cur_icon.scale = lerp(cur_icon.scale, Vector2.ONE, delta * 9.0)
	
	Conductor.songPosition = inst.get_playback_position() * 1000.0
	inst.pitch_scale = Globals.song_multiplier
	
	for i in song_nodes.size():
		var song: FreeplaySong = song_nodes[i]
		Globals.position_menu_alphabet(song, i - selected, delta)
	
	if Input.is_action_just_pressed('ui_accept') and not selected_song:
		selected_song = true
		AudioHandler.play_audio('Confirm Sound')
		
		Globals.songName = songs[selected]
		Globals.songDifficulty = 'hard' if difficulties.is_empty() else \
				difficulties[selected_difficulty].to_lower()
		
		Globals.freeplay = true
		
		var file := FileAccess.open(Paths.song_path(Globals.songName, Globals.songDifficulty), FileAccess.READ)
		
		var test_json_conv = JSON.new()
		test_json_conv.parse(file.get_as_text())
		Globals.song = test_json_conv.get_data()['song']
		Scenes.switch_scene('Gameplay')
	
	if selected_song:
		return
	
	if Input.is_action_pressed('ui_shift'):
		_speed_menu_input(delta)
	else:
		_difficulty_menu_input()
	
	if Input.is_action_just_pressed('ui_up'):
		_change_item(-1, delta)
	if Input.is_action_just_pressed('ui_down'):
		_change_item(1, delta)
	
	if Input.is_action_just_pressed('ui_back'):
		AudioHandler.stop_audio('Inst')
		Scenes.switch_scene('Main Menu')

func _difficulty_menu_input() -> void:
	var axis: int = round(Input.get_axis('ui_left', 'ui_right'))
	
	if axis and (Input.is_action_just_pressed('ui_left') or \
			Input.is_action_just_pressed('ui_right')):
		selected_difficulty += -axis
		
		if selected_difficulty > difficulties.size() - 1:
			selected_difficulty = 0
		if selected_difficulty < 0:
			selected_difficulty = difficulties.size() - 1
		
		if not difficulties.is_empty():
			score = Scores.get_song_score(songs[selected].to_lower(), difficulties[selected_difficulty].to_lower())

func _speed_menu_input(delta: float) -> void:
	if Input.is_action_just_pressed('ui_reset'):
		Globals.song_multiplier = 1.0
	
	if Input.is_action_pressed('ui_left') and multi_timer > 0.1:
		_change_speed(-0.05)
	if Input.is_action_pressed('ui_right') and multi_timer > 0.1:
		_change_speed(0.05)
	
	if Input.is_action_just_pressed('ui_left') or Input.is_action_just_pressed('ui_right'):
		multi_timer = 0.11
	
	if Input.is_action_pressed('ui_left') or Input.is_action_pressed('ui_right'):
		multi_timer += delta
	else:
		multi_timer = 0

func _change_speed(amount: float) -> void:
	multi_timer = 0
	Globals.song_multiplier = clamp(Globals.song_multiplier + amount, 0.05, INF)

func _change_item(amount: int = 0, delta: float = 0.0) -> void:
	selected = wrapi(selected + amount, 0, song_nodes.size())
	
	AudioHandler.play_audio('Scroll Menu')
	
	var selected_child := songs_node.get_child(selected)
	
	for child in songs_node.get_children():
		if child != selected_child:
			child.modulate.a = 0.5
			
			child.get_node('Icon').frame = 0
			child.get_node('Icon').scale = Vector2(1, 1)
		else:
			child.modulate.a = 1
			
			if child.get_node('Icon').hframes >= 3:
				child.get_node('Icon').frame = 2
	
	var directory: DirAccess = DirAccess.open('res://Assets/Songs/%s/' % songs[selected].to_lower())
	directory.list_dir_begin() # TODOConverter3To4 fill missing arguments https://github.com/godotengine/godot/pull/40547
	
	difficulties = []
	
	while true:
		var file = directory.get_next()
		
		if file == '':
			break
		elif file.ends_with('.json'):
			difficulties.append(file.replace('.json', ''))
	
	if difficulties.has('events'):
		difficulties.erase('events')
	
	for difficulty in selected_child.ignore_difficulties:
		if difficulties.has(difficulty):
			difficulties.erase(difficulty)
	
	if selected_difficulty > difficulties.size() - 1:
		selected_difficulty = difficulties.size() - 1
	
	if tween != null:
		tween.kill()
		tween = null
	
	tween = create_tween()
	tween.tween_property(bg, 'modulate', selected_child.freeplay_color, 0.5)
	
	if not difficulties.is_empty():
		score = Scores.get_song_score(songs[selected].to_lower(), \
				difficulties[selected_difficulty])
	
	if Settings.get_data('freeplay_music'):
		inst.stream = load('res://Assets/Songs/' + songs[selected].to_lower() + '/Inst.ogg')
		inst.volume_db = 0
		AudioHandler.stop_audio('Title Music')
		AudioHandler.play_audio('Inst')
		
		Globals.songName = songs[selected]
		
		Globals.songDifficulty = 'hard' if difficulties.is_empty() else \
				difficulties[selected_difficulty].to_lower()
		
		var file := FileAccess.open(Paths.song_path(Globals.songName, Globals.songDifficulty), FileAccess.READ)
		
		var test_json_conv = JSON.new()
		test_json_conv.parse(file.get_as_text())
		Conductor.change_bpm(float(test_json_conv.get_data()['song']['bpm']))
	
	cur_icon = songs_node.get_child(selected).get_node('Icon')

func beat_hit() -> void:
	songs_node.get_child(selected).get_node('Icon').scale = Vector2(1.2, 1.2)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_change_item(1)
		elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_change_item(-1)
