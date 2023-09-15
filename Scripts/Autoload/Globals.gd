extends Node

# GameplaySettings
var songName: String = 'tutorial'
var songDifficulty: String = 'hard'

var weekSongs: Array = []

var freeplay: bool = false

var scroll_speed: float = 1.0

var key_count: int = 4

var death_character_name: String = 'bf-dead'
var death_character_pos: Vector2 = Vector2()
var death_character_cam: Vector2 = Vector2()

var song_multiplier: float = 1.0

var do_cutscenes: bool = true

# song data lmao (used for loading into Gameplay i think)
var song: Dictionary

func int_to_dir(i: int, k: int) -> String:
	var keys = load('res://Scenes/Gameplay/Strums/%d.tscn' % k).instantiate()
	
	if keys.get_child(i):
		var return_value: String = keys.get_child(i).name.to_lower()
		keys.queue_free()
		return return_value
	
	return ''

# bullshit function that is used to make life easier for modders
static func dir_to_animstr(dir: String) -> String:
	var str_dir = dir.to_lower()
	# weird conversion shit
	str_dir = str_dir.replace('2', '')
	
	if str_dir.begins_with('r'):
		str_dir = str_dir.right(-1)
	if str_dir == 'ight':
		str_dir = 'right'
	
	match(str_dir):
		'plus', 'square':
			return 'up'
	
	return str_dir

# NoteGlobals
# hardcoded sprite bullshit because static variables don't exist :(
var held_sprites: Dictionary = {
	'left': [
		preload('res://Assets/Images/Notes/default/held/left hold0000.png'),
		preload('res://Assets/Images/Notes/default/held/left hold end0000.png')
	],
	'down': [
		preload('res://Assets/Images/Notes/default/held/down hold0000.png'),
		preload('res://Assets/Images/Notes/default/held/down hold end0000.png')
	],
	'up': [
		preload('res://Assets/Images/Notes/default/held/up hold0000.png'),
		preload('res://Assets/Images/Notes/default/held/up hold end0000.png')
	],
	'right': [
		preload('res://Assets/Images/Notes/default/held/right hold0000.png'),
		preload('res://Assets/Images/Notes/default/held/right hold end0000.png')
	],
	'square': [
		preload('res://Assets/Images/Notes/default/held/square hold0000.png'),
		preload('res://Assets/Images/Notes/default/held/square hold end0000.png')
	],
	'left2': [
		preload('res://Assets/Images/Notes/default/held/left2 hold0000.png'),
		preload('res://Assets/Images/Notes/default/held/left2 hold end0000.png')
	],
	'down2': [
		preload('res://Assets/Images/Notes/default/held/down2 hold0000.png'),
		preload('res://Assets/Images/Notes/default/held/down2 hold end0000.png')
	],
	'up2': [
		preload('res://Assets/Images/Notes/default/held/up2 hold0000.png'),
		preload('res://Assets/Images/Notes/default/held/up2 hold end0000.png')
	],
	'right2': [
		preload('res://Assets/Images/Notes/default/held/right2 hold0000.png'),
		preload('res://Assets/Images/Notes/default/held/right2 hold end0000.png')
	],
	'rleft': [
		preload('res://Assets/Images/Notes/default/held/rleft hold0000.png'),
		preload('res://Assets/Images/Notes/default/held/rleft hold end0000.png')
	],
	'rdown': [
		preload('res://Assets/Images/Notes/default/held/rdown hold0000.png'),
		preload('res://Assets/Images/Notes/default/held/rdown hold end0000.png')
	],
	'rup': [
		preload('res://Assets/Images/Notes/default/held/rup hold0000.png'),
		preload('res://Assets/Images/Notes/default/held/rup hold end0000.png')
	],
	'rright': [
		preload('res://Assets/Images/Notes/default/held/rright hold0000.png'),
		preload('res://Assets/Images/Notes/default/held/rright hold end0000.png')
	],
	'plus': [
		preload('res://Assets/Images/Notes/default/held/plus hold0000.png'),
		preload('res://Assets/Images/Notes/default/held/plus hold end0000.png')
	],
	'rleft2': [
		preload('res://Assets/Images/Notes/default/held/rleft2 hold0000.png'),
		preload('res://Assets/Images/Notes/default/held/rleft2 hold end0000.png')
	],
	'rdown2': [
		preload('res://Assets/Images/Notes/default/held/rdown2 hold0000.png'),
		preload('res://Assets/Images/Notes/default/held/rdown2 hold end0000.png')
	],
	'rup2': [
		preload('res://Assets/Images/Notes/default/held/rup2 hold0000.png'),
		preload('res://Assets/Images/Notes/default/held/rup2 hold end0000.png')
	],
	'rright2': [
		preload('res://Assets/Images/Notes/default/held/rright2 hold0000.png'),
		preload('res://Assets/Images/Notes/default/held/rright2 hold end0000.png')
	],
}

var leaked_cache: Array = []

static func unleak_memory() -> void:
	Globals.leaked_cache.clear()

static func leak_memory() -> void:
	leak_some_vram('res://Assets/')
	leak_some_vram('res://Scenes/')
	leak_some_vram('res://Scripts/')

static func leak_some_vram(path: String) -> void:
	for asset_path in get_filelist(path):
		Globals.leaked_cache.push_back(load(asset_path))

static func get_filelist(scan_dir: String) -> Array:
	var my_files: Array = []
	var dir: DirAccess = DirAccess.open(scan_dir)
	
	if dir == null:
		printerr('Warning: could not open directory: ', DirAccess.get_open_error())
		return []

	if dir.list_dir_begin() != OK:# TODOConverter3To4 fill missing arguments https://github.com/godotengine/godot/pull/40547
		printerr('Warning: could not list contents of: ', scan_dir)
		return []

	var file_name: String = dir.get_next()
	
	while file_name != '':
		if dir.current_is_dir(): my_files += get_filelist(dir.get_current_dir() + '/' + file_name)
		else: my_files.append(dir.get_current_dir() + '/' + file_name)
		
		file_name = dir.get_next()
	
	return my_files

signal _ready_post()

# self explanatory
signal player_note_hit(note, dir, type, character)
signal enemy_note_hit(note, dir, type, character)
# must_hit is basically asking if it's a player side note or not btw
signal note_hit(note, dir, type, character, must_hit)

# called when the player misses a note
signal note_miss(note, dir, type, character)

# self explanatory
signal camera_moved(character)

# called every time an event is setup (not sure if this is useful, but better be safe than sorry)
signal event_setup(event)

# called every time an event is triggered
signal event_processed(event)

# formats time into minutes:seconds
static func format_time(seconds: float) -> String:
	var minutes_int: int = int(seconds / 60.0)
	var seconds_int: int = int(seconds) % 60
	var seconds_string: String = '0' + str(seconds_int) if seconds_int < 10 else str(seconds_int)
	
	return '%s:%s' % [minutes_int, seconds_string]

# formats bytes into readable values
const byte_formats: PackedStringArray = ['kb', 'mb', 'gb']

static func format_bytes(bytes: int, precision: int = 2) -> String:
	var formatted_bytes: String = '%sb' % bytes
	
	for i in byte_formats.size():
		var format: String = byte_formats[i]
		
		if bytes >= pow(1024.0, i + 1):
			formatted_bytes = '%s%s' % [format_float(bytes / pow(1024.0, i + 1), precision), format]
		else:
			break
	
	return formatted_bytes

# formatting numbers with precision

static func format_float(input: float, precision: int) -> float:
	var multiplier: float = pow(10, precision)
	return int(input * multiplier) / multiplier

# lerp value
static func lerpv(value_60: float, delta: float) -> float:
	return delta * 60.0 * value_60

# good lerp
static func glerp(value_1, value_2, lerp_value: float, delta: float):
	return lerpf(float(value_1), float(value_2), lerpv(lerp_value, delta))

# lazy.exe
static func hxzoom_to_gdzoom(hxzoom: float) -> float:
	return hxzoom

# easy error checking
static func load_character(character: String, default: String = '') -> Resource:
	if character == '':
		character = ' '
	if ResourceLoader.exists(Paths.char_path(character)):
		return load(Paths.char_path(character))
	else:
		printerr('Character %s does not exist! Loading default %s.' % [character, default])
		return load(Paths.char_path(default))

# easy error checking (but stage)
static func load_stage(stage: String, default: String = '') -> Resource:
	if stage == '':
		stage = ' '
	if ResourceLoader.exists(Paths.stage_path(stage)):
		return load(Paths.stage_path(stage))
	else:
		printerr('Stage %s does not exist! Loading default %s.' % [stage, default])
		return load(Paths.stage_path(default))

# lazy leather moment
static func load_song_audio(audio: String):
	var song_path: String = 'res://Assets/Songs/' + Globals.songName.to_lower() + '/'
	
	var target_path: String = '%s%s-%s.ogg' % [song_path, audio, Globals.songDifficulty.to_lower()]
	var fallback_path: String = '%s%s.ogg' % [song_path, audio]
	
	if ResourceLoader.exists(target_path):
		return load(target_path)
	else:
		return load(fallback_path)

# better modularity
static func detect_icon_frames(icon: Sprite2D) -> void:
	if not icon.texture:
		return
	
	icon.hframes = 3
	
	if icon.texture.get_width() <= 300:
		icon.hframes = 2
	if icon.texture.get_width() <= 150:
		icon.hframes = 1
	
	if icon.texture.get_height() != 150:
		icon.hframes = 2

static func position_menu_alphabet(text: Control, target_y: int, delta: float):
	var scaled_y: float = remap(target_y, 0, 1, 0, 1.3)
	var lerp_value: float = clampf(delta * 9.6, 0.0, 1.0)
	
	# 120 = yMult, 720 = FlxG.height
	text.position.x = lerpf(text.position.x, (target_y * 20.0) + 90.0, lerp_value)
	text.position.y = lerpf(text.position.y, (scaled_y * 120.0) + (720.0 * 0.48), lerp_value)

# other functions #
func _ready() -> void:
	RenderingServer.set_default_clear_color(Color.BLACK)
	
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	if Settings.get_data('memory_leaks'):
		leak_memory()
	Engine.max_fps = Settings.get_data('fps_cap')

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed('ui_fullscreen'):
		get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN if (!((get_window().mode == Window.MODE_EXCLUSIVE_FULLSCREEN) or (get_window().mode == Window.MODE_FULLSCREEN))) else Window.MODE_WINDOWED
	if Input.is_action_just_pressed('restart_scene'):
		get_tree().reload_current_scene()
