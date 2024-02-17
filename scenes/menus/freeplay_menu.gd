extends Node2D


static var index: int = 0
static var difficulty_index: int = 0

@export var list: FreeplayList = preload('res://resources/freeplay_list.tres')

@onready var background: Sprite2D = $background
@onready var songs = $songs
var song_nodes: Array[FreeplaySongNode] = []

@onready var song_label: Label = $root_control/panel_container/song_label
@onready var accuracy_label: Label = $root_control/panel_container/accuracy_label
@onready var difficulty_label: Label = $root_control/panel_container/difficulty_label
@onready var track: AudioStreamPlayerEX = $track
@onready var track_timer: Timer = $track_timer

var list_song: FreeplaySong:
	get: return list.list[index]

var difficulties: PackedStringArray:
	get: return list_song.song_difficulties

var difficulty: String:
	get: return difficulties[difficulty_index]

var active: bool = true


func _ready():
	randomize()
	
	for i in list.list.size():
		_load_song(i)
	
	background.modulate = song_nodes[index].song.icon.color
	change_selection()


func _process(delta: float) -> void:
	for i in song_nodes.size():
		var node := song_nodes[i]
		node.target_y = i - index
		node.modulate.a = 1.0 if node.target_y == 0 else 0.6
	
	background.modulate = background.modulate.lerp(
			song_nodes[index].song.icon.color, delta * 5.0)


func _input(event: InputEvent) -> void:
	if not active:
		return
	if not event.is_pressed():
		return
	if event.is_action('freeplay_random'):
		change_selection(randi_range(-song_nodes.size() + 1, song_nodes.size() - 1))
	if event.is_action('ui_up') or event.is_action('ui_down'):
		change_selection(Input.get_axis('ui_up', 'ui_down'))
	if event.is_action('ui_left') or event.is_action('ui_right'):
		change_difficulty(Input.get_axis('ui_left', 'ui_right'))
	if event.is_action('ui_accept') and event.is_pressed():
		active = false
		call_deferred('select_song')


func change_selection(amount: int = 0) -> void:
	index = wrapi(index + amount, 0, song_nodes.size())
	change_difficulty()
	
	song_label.text = song_nodes[index].text
	track.stop()
	track_timer.start(0.0)
	
	if amount != 0:
		GlobalAudio.get_player('MENU/SCROLL').play()


func change_difficulty(amount: int = 0) -> void:
	difficulty_index = wrapi(difficulty_index + amount, 0, difficulties.size())
	
	if difficulties.is_empty():
		difficulty_label.text = '< N/A >'
	else:
		difficulty_label.text = '< %s >' % difficulty.to_upper()


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
	if not FileAccess.file_exists(json_path):
		active = true
		return
	
	var funkin_chart := FunkinChart.new()
	var json_string := FileAccess.get_file_as_string(json_path)
	funkin_chart.json = JSON.parse_string(json_string)
	
	Game.song = song_name
	Game.difficulty = difficulty.to_lower()
	Game.chart = funkin_chart.parse()
	Game.mode = Game.PlayMode.FREEPLAY
	SceneManager.switch_to('scenes/game/game.tscn')


func _load_song(i: int) -> void:
	var song := list.list[i]
	var meta_path: String = 'res://songs/%s/meta.tres' % song.song_name.to_lower()
	var meta_exists := ResourceLoader.exists(meta_path)
	
	if meta_exists:
		song.song_meta = load(meta_path)
	else:
		song.song_meta = SongMetadata.new()
	
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
	
	var tracks: SongTracks = load('res://songs/%s/tracks.tres' \
			% list_song.song_name.to_lower())
	
	if tracks.tracks.is_empty():
		return
	
	GlobalAudio.get_player('MUSIC').stop()
	
	var song_track := tracks.tracks[0]
	track.stream = song_track.stream
	track.volume_db = song_track.volume - 6.0
	track.bus = song_track.bus
	track.play()
