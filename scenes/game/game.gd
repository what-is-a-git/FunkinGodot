class_name Game extends Node2D


static var song: StringName = &'bopeebo'
static var difficulty: StringName = &'hard'
static var chart: Chart = null
static var scroll_speed: float = 3.3
static var mode: PlayMode = PlayMode.FREEPLAY

static var instance: Game = null
static var playlist: Array[GamePlaylistEntry] = []
static var camera_position: Vector2 = Vector2.INF
static var camera_zoom: Vector2 = Vector2.INF

@onready var pause_menu: PackedScene = load('res://scenes/game/pause_menu.tscn')

@onready var accuracy_calculator: AccuracyCalculator = %accuracy_calculator
@onready var tracks: Tracks = %tracks
@onready var scripts: ScriptContainer = %scripts
@onready var camera: Camera2D = $camera

@onready var hud_layer: CanvasLayer = %hud_layer
@onready var hud: HUD = %hud
@onready var _player_field: NoteField = hud.player_field
@onready var _opponent_field: NoteField = hud.opponent_field

var target_camera_position: Vector2 = Vector2.ZERO
var target_camera_zoom: Vector2 = Vector2(1.05, 1.05)
var camera_bump_amount: Vector2 = Vector2(0.015, 0.015)
var camera_lerps: bool = true
var camera_bumps: bool = false
var song_started: bool = false
var save_score: bool = true

# Used for fixing lerping delta issues when restarting songs :p
var _first_frame: bool = true
@onready var _stage: Node2D = $stage
@onready var _characters: Node2D = $characters

## Each note type is stored here for use in any note field.
var note_types := NoteTypes.new()

var playing: bool = true

var assets: SongAssets
var metadata: SongMetadata

var player: Character
var opponent: Character
var spectator: Character
var stage: Stage

var health: float = 50.0
var score: int = 0
var misses: int = 0
var combo: int = 0
var accuracy: float = 0.0:
	get:
		if is_instance_valid(accuracy_calculator):
			return accuracy_calculator.get_accuracy()
		
		return 0.0
var rank: String:
	get:
		if is_instance_valid(hud.health_bar):
			return hud.health_bar.rank
		
		return 'N/A'

var skin: HUDSkin
@onready var _default_note := load('res://scenes/game/notes/note.tscn')
var _event: int = 0

signal hud_setup
signal ready_post
signal process_post(delta: float)
signal song_start
signal event_prepare(event: EventData)
signal event_hit(event: EventData)
signal song_finished(event: CancellableEvent)
signal scroll_speed_changed
signal died(event: CancellableEvent)


func _init() -> void:
	instance = self
	
	if not chart:
		chart = Chart.load_song(song, difficulty)
	if ResourceLoader.exists('res://songs/%s/meta.tres' % song):
		metadata = load('res://songs/%s/meta.tres' % song)


func _exit_tree() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	GlobalAudio.music.stop()
	tracks.load_tracks(song)
	tracks.finished.connect(_song_finished)
	
	match Config.get_value('gameplay', 'scroll_speed_method'):
		'chart':
			scroll_speed *= Config.get_value('gameplay', 'custom_scroll_speed')
		'constant':
			scroll_speed = Config.get_value('gameplay', 'custom_scroll_speed')
	
	scroll_speed_changed.emit()
	
	if ResourceLoader.exists('res://songs/%s/events.tres' % song):
		var events: SongEvents = load('res://songs/%s/events.tres' % song)
		chart.events.append_array(events.events)
	
	Chart.sort_chart_notes(chart)
	Chart.sort_chart_events(chart)
	
	note_types.types['default'] = _default_note
	
	# loading external types :3
	for note in chart.notes:
		if note_types.types.has(note.type):
			continue
		var path := 'res://scenes/game/notes/%s.tscn' % note.type
		if not ResourceLoader.exists(path):
			continue
		
		note_types.types[note.type] = load(path)
	
	if ResourceLoader.exists('res://songs/%s/assets.tres' % song):
		# Load SongAssets tres.
		assets = load('res://songs/%s/assets.tres' % song)
		
		if not is_instance_valid(assets.player):
			assets.player = load('res://scenes/game/assets/characters/bf.tscn')
		if not is_instance_valid(assets.opponent):
			assets.opponent = load('res://scenes/game/assets/characters/dad.tscn')
		if not is_instance_valid(assets.spectator):
			assets.spectator = load('res://scenes/game/assets/characters/gf.tscn')
		if not is_instance_valid(assets.stage):
			assets.stage = load('res://scenes/game/assets/stages/stage.tscn')
		if not is_instance_valid(assets.hud_skin):
			assets.hud_skin = load('res://resources/hud_skins/default.tres')
		
		# Instantiate the PackedScene(s) and add them to the scene.
		player = assets.player.instantiate()
		opponent = assets.opponent.instantiate()
		spectator = assets.spectator.instantiate()
		_characters.add_child(spectator)
		_characters.add_child(player)
		_characters.add_child(opponent)
		
		stage = assets.stage.instantiate()
		_stage.add_child(stage)
		target_camera_zoom = Vector2(stage.default_zoom, stage.default_zoom)
		camera.zoom = target_camera_zoom
		
		# Position and scale the characters.
		var player_point: Node2D = stage.get_node('player')
		var opponent_point: Node2D = stage.get_node('opponent')
		var spectator_point: Node2D = stage.get_node('spectator')
		player.global_position = player_point.global_position
		
		if not player.starts_as_player:
			player.scale *= Vector2(-1.0, 1.0) * player_point.scale
		
		player._is_player = true
		opponent.global_position = opponent_point.global_position
		opponent.scale *= opponent_point.scale
		spectator.global_position = spectator_point.global_position
		spectator.scale *= spectator_point.scale
		
		if is_instance_valid(assets.hud):
			hud.free()
			hud = assets.hud.instantiate()
			hud_layer.add_child(hud)
			_player_field = hud.player_field
			_opponent_field = hud.opponent_field
		
		# Set the NoteField characters.
		_player_field._default_character = player
		_opponent_field._default_character = opponent
		
		skin = assets.hud_skin
		
		if is_instance_valid(skin.pause_menu):
			pause_menu = skin.pause_menu
	else:
		skin = load('res://resources/hud_skins/default.tres')
	
	_player_field._note_types = note_types
	_opponent_field._note_types = note_types
	_player_field.note_miss.connect(_on_note_miss)
	_player_field.note_hit.connect(_on_note_hit)
	_opponent_field.note_hit.connect(func(note: Note):
		camera_bumps = true)
	
	hud.setup()
	hud_setup.emit()
	
	Conductor.reset()
	Conductor.beat_hit.connect(_on_beat_hit)
	Conductor.measure_hit.connect(_on_measure_hit)
	scripts.load_scripts(song)
	
	if not chart.events.is_empty():
		# Note: this means all custom events just act as normal scripts
		# which should be fine for 99.9% of use cases.
		# it also means you have to manually check for event names
		# but it's fine :p
		var exceptions: Array[StringName] = []
		for event in chart.events:
			var event_name: StringName = event.name.to_lower()
			if exceptions.has(event_name):
				continue
			exceptions.push_back(event_name)
			
			var path: String = 'res://scenes/game/events/%s.tscn' % [event_name]
			if not ResourceLoader.exists(path):
				continue
			
			var scene: PackedScene = load(path)
			var node: Node = scene.instantiate()
			scripts.add_child(node)
		
		for event in chart.events:
			event_prepare.emit(event)
		
		while (not chart.events.is_empty()) and _event < chart.events.size() \
				and chart.events[_event].time <= 0.0:
			_on_event_hit(chart.events[_event])
			_event += 1
	
	Conductor.time = (-4.0 / Conductor.beat_delta) + Conductor.offset
	Conductor.beat = -4.0
	Conductor.beat_hit.emit(Conductor.beat)
	
	var window := get_tree().get_root()
	window.size_changed.connect(func():
		if song_started:
			tracks.check_sync(true)
	)
	
	if camera_position != Vector2.INF:
		camera.position = camera_position
	if camera_zoom != Vector2.INF:
		camera.zoom = camera_zoom
	ready_post.emit()


func _process(delta: float) -> void:
	call_deferred('_process_post', delta)
	camera_position = camera.position
	camera_zoom = camera.zoom
	
	if not playing:
		return
	
	if health <= 0.0:
		var event: CancellableEvent = CancellableEvent.new()
		died.emit(event)
		
		if event.status == CancellableEvent.EventStatus.CONTINUE:
			Gameover.camera_position = camera.global_position
			Gameover.camera_zoom = camera.zoom
			Gameover.character_path = player.death_character
			Gameover.character_position = player.global_position
			SceneManager.switch_to('scenes/game/gameover.tscn', false)
			return
	
	if is_instance_valid(tracks) and not song_started:
		if Conductor.time >= Conductor.offset and not tracks.playing:
			tracks.play()
			Conductor.beat = Conductor.offset / Conductor.beat_delta
			Conductor.target_audio = tracks.player
			song_start.emit()
			song_started = true
	
	while _event < chart.events.size() and \
			Conductor.time >= chart.events[_event].time:
		var event := chart.events[_event]
		_on_event_hit(event)
		_event += 1
	
	if _first_frame:
		_first_frame = false
		return
	if camera_lerps:
		camera.position = camera.position.lerp(target_camera_position, delta * 3.0)
		if camera_bumps:
			camera.zoom = camera.zoom.lerp(target_camera_zoom, delta * 3.0)


func _process_post(delta: float) -> void:
	process_post.emit(delta)


func _input(event: InputEvent) -> void:
	if not event.is_pressed():
		return
	if event.is_echo():
		return
	if not playing:
		return
	if event.is_action('ui_cancel'):
		_song_finished(true)
	if event.is_action('pause_game'):
		var menu: CanvasLayer = pause_menu.instantiate()
		add_child(menu)
		process_mode = Node.PROCESS_MODE_DISABLED
		Conductor.process_mode = Node.PROCESS_MODE_DISABLED
	if event.is_action('toggle_botplay'):
		save_score = false
		_player_field.takes_input = not _player_field.takes_input
		
		for receptor: Receptor in _player_field._receptors:
			receptor.takes_input = _player_field.takes_input
			receptor._automatically_play_static = not _player_field.takes_input
		
		if 'song_label' in hud:
			if not _player_field.takes_input:
				hud.song_label.text += ' [BOT]'
			elif hud.song_label.text.contains(' [BOT]'):
				hud.song_label.text = hud.song_label.text.replace(' [BOT]', '')


func _on_beat_hit(beat: int) -> void:
	player.dance()
	opponent.dance()
	spectator.dance()


func _on_measure_hit(measure: int) -> void:
	if not camera_bumps:
		return
	
	camera.zoom += camera_bump_amount


func _on_event_hit(event: EventData) -> void:
	event_hit.emit(event)


func _on_note_miss(note: Note) -> void:
	accuracy_calculator.record_hit(Receptor.input_zone)
	health = clampf(health - 2.0, 0.0, 100.0)
	misses += 1
	score -= 10
	combo = 0


func _on_note_hit(note: Note) -> void:
	combo += 1


func _song_finished(force: bool = false) -> void:
	if not playing:
		return
	
	var event: CancellableEvent = CancellableEvent.new()
	if not force:
		song_finished.emit(event)
	else:
		save_score = false
	
	if event.status == CancellableEvent.EventStatus.CANCEL:
		return
	
	playing = false
	if save_score:
		var current_score := Scores.get_score(song, difficulty)
		
		if str(current_score.get('score', 'N/A')) == 'N/A' or score > current_score.get('score'):
			Scores.set_score(song, difficulty, {
				'score': score,
				'misses': misses,
				'accuracy': accuracy,
				'rank': rank
			})
	
	if not (playlist.is_empty() or force):
		var new_song: StringName = playlist[0].name
		var new_difficulty: StringName = playlist[0].difficulty
		chart = Chart.load_song(new_song, new_difficulty)
		
		if not is_instance_valid(chart):
			var json_path := 'res://songs/%s/charts/%s.json' % [new_song, new_difficulty.to_lower()]
			printerr('Song at path %s doesn\'t exist!' % json_path)
			GlobalAudio.get_player('MENU/CANCEL').play()
			SceneManager.switch_to('scenes/menus/main_menu.tscn')
			playlist.clear()
			return
		
		song = new_song
		difficulty = new_difficulty.to_lower()
		playlist.pop_front()
		get_tree().reload_current_scene()
		return
	
	chart = null
	instance = null
	playlist.clear()
	camera_position = Vector2.INF
	camera_zoom = Vector2.INF
	GlobalAudio.get_player('MENU/CANCEL').play()
	match mode:
		PlayMode.STORY:
			SceneManager.switch_to('scenes/menus/story_mode_menu.tscn')
		PlayMode.FREEPLAY:
			SceneManager.switch_to('scenes/menus/freeplay_menu.tscn')
		_:
			SceneManager.switch_to('scenes/menus/title_screen.tscn')


func countdown_resume() -> void:
	hud.countdown_resume()


enum PlayMode {
	FREEPLAY = 0,
	STORY = 1,
	OTHER = 2,
}
