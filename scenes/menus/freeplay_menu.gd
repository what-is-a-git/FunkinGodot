extends Node2D


static var index: int = 0
static var difficulty_index: int = 0

@onready var list: FreeplayList = load('res://resources/freeplay_list.tres')

@onready var background: Sprite2D = $background
var target_background_color: Color = Color.WHITE
@onready var songs = $songs
var song_nodes: Array[FreeplaySongNode] = []

@onready var track: AudioStreamPlayer = $track
@onready var track_timer: Timer = $track_timer

# hacky workaround for looping audiostreamsynced atm :3
var last_track_position: float = -INF

var list_song: FreeplaySong:
	get: return list.list[index]

var difficulties: PackedStringArray:
	get: return list_song.song_difficulties

var difficulty: String:
	get: return difficulties[difficulty_index]

var active: bool = true

signal song_changed(index: int)
signal difficulty_changed(difficulty: StringName)


func _ready() -> void:
	randomize()
	
	for i in list.list.size():
		_load_song(i)
	
	if song_nodes.is_empty():
		active = false
		GlobalAudio.get_player('MENU/CANCEL').play()
		SceneManager.switch_to('scenes/menus/main_menu.tscn')
		printerr('Freeplay has no songs, returning.')
		return
	
	target_background_color = song_nodes[index].song.icon.color
	background.modulate = target_background_color
	change_selection()


func _process(delta: float) -> void:
	background.modulate = background.modulate.lerp(target_background_color, delta * 5.0)
	
	if is_instance_valid(track.stream):
		# SHIT DON'T GO BACK NOW DUZ IT?
		if track.get_playback_position() < last_track_position:
			track.playing = false
		
		if not track.playing:
			track.play()
	
	last_track_position = track.get_playback_position()


func _input(event: InputEvent) -> void:
	if not active:
		return
	if not event.is_pressed():
		return
	
	if event.is_action('ui_cancel'):
		active = false
		GlobalAudio.get_player('MENU/CANCEL').play()
		SceneManager.switch_to('scenes/menus/main_menu.tscn')
	if event.is_action('ui_accept'):
		active = false
		call_deferred('select_song')
	
	if event.is_action('ui_up') or event.is_action('ui_down'):
		change_selection(Input.get_axis('ui_up', 'ui_down'))
	if event.is_action('ui_left') or event.is_action('ui_right'):
		change_difficulty(Input.get_axis('ui_left', 'ui_right'))
	
	if event.is_action('freeplay_random'):
		change_selection(randi_range(-song_nodes.size() + 1, song_nodes.size() - 1))


func change_selection(amount: int = 0) -> void:
	index = wrapi(index + amount, 0, song_nodes.size())
	song_changed.emit(index)
	
	target_background_color = song_nodes[index].song.icon.color
	change_difficulty()
	
	track.stop()
	track.stream = null
	track_timer.start(0.0)
	
	if amount != 0:
		GlobalAudio.get_player('MENU/SCROLL').play()
	
	for i in song_nodes.size():
		var node := song_nodes[i]
		node.target_y = i - index
		node.modulate.a = 1.0 if node.target_y == 0 else 0.6


func change_difficulty(amount: int = 0) -> void:
	difficulty_index = wrapi(difficulty_index + amount, 0, difficulties.size())
	if difficulties.is_empty():
		difficulty_changed.emit(&'N/A')
	else:
		difficulty_changed.emit(difficulties[difficulty_index])


func select_song() -> void:
	if difficulties.is_empty():
		active = true
		return
	
	var song_name: StringName = list_song.song_name.to_lower()
	var difficulty_remap := list_song.difficulty_remap
	
	if is_instance_valid(difficulty_remap) and not difficulty_remap.mapping.is_empty():
		for key in difficulty_remap.mapping.keys():
			if key.to_lower() == difficulty.to_lower():
				song_name = difficulty_remap.mapping.get(key, &'').to_lower()
				break
	
	var json_path := 'res://songs/%s/charts/%s.json' % [song_name, difficulty.to_lower()]
	Game.chart = Chart.load_song(song_name, difficulty)
	
	if not is_instance_valid(Game.chart):
		active = true
		printerr('Song at path %s doesn\'t exist!' % json_path)
		return
	
	Game.song = song_name
	Game.difficulty = difficulty.to_lower()
	Game.mode = Game.PlayMode.FREEPLAY
	SceneManager.switch_to('scenes/game/game.tscn')


func _load_song(i: int) -> void:
	var song := list.list[i]
	var meta_path: String = 'res://songs/%s/meta.tres' % song.song_name.to_lower()
	var meta_exists := ResourceLoader.exists(meta_path)
	
	if not meta_exists:
		printerr('There is no metadata for song %s! Path to metadata should be: "res://songs/%s/meta.tres"' \
				% [song.song_name, song.song_name.to_lower()])
		return
	
	song.song_meta = load(meta_path)
	
	var node := FreeplaySongNode.new()
	node.position = Vector2.ZERO
	node.song = song
	node.text = song.song_meta.display_name if meta_exists else song.song_name
	node.target_y = i
	song_nodes.push_back(node)
	songs.add_child(node)
	
	if not is_instance_valid(song.icon):
		return
	
	var icon := Icon.create_sprite(song.icon)
	# 37.5 = 150.0 * 0.25
	icon.position = Vector2(node.bounding_box.x + 75.0, 37.5)
	node.add_child(icon)


func _load_tracks() -> void:
	if not ResourceLoader.exists('res://songs/%s/tracks.tres' \
			% list_song.song_name.to_lower()):
		return
	
	var tracks: AudioStream = load('res://songs/%s/tracks.tres' \
			% list_song.song_name.to_lower())
	
	if not is_instance_valid(tracks):
		return
	
	GlobalAudio.get_player('MUSIC').stop()
	
	track.stream = tracks
	track.play()
