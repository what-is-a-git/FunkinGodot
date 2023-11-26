extends Node

# default save values
var og_save: Dictionary = {
	'flashingLights': true,
	'cameraZooms': true,
	'downscroll': false,
	'opponent_note_glow': true,
	'volume': 0,
	'muted': false,
	'binds_1': ['SPACE'],
	'binds_2': ['D', 'K'],
	'binds_3': ['D', 'SPACE', 'K'],
	'binds_4': ['D', 'F', 'J', 'K'],
	'binds_5': ['D', 'F', 'SPACE', 'J', 'K'],
	'binds_6': ['S', 'D', 'F', 'J', 'K', 'L'],
	'binds_7': ['S', 'D', 'F', 'SPACE', 'J', 'K', 'L'],
	'binds_8': ['A', 'S', 'D', 'F', 'H', 'J', 'K', 'L'],
	'binds_9': ['A', 'S', 'D', 'F', 'SPACE', 'H', 'J', 'K', 'L'],
	'bot': false,
	'offset': 0,
	'middlescroll': false,
	'active_mods': [],
	'vsync': false,
	'debug_menus': true,
	'new_sustain_animations': true,
	'memory_leaks': false,
	'miss_sounds': true,
	'charter_hitsounds': false,
	'ultra_performance': false,
	'scene_transitions': true,
	'hitsounds': false,
	'hitsound': 'osu mania',
	'freeplay_cutscenes': false,
	'health_icon_bounce': 'default',
	'custom_scroll_bool': false,
	'custom_scroll': 1.0,
	'story_mode_icons': true,
	'note_render_style': 'default',
	'song_scores': {},
	'week_scores': {},
	'freeplay_music': true,
	'preload_notes': true,
	'fps_cap': 0,
	'side_ratings_enabled': true,
	'progress_bar_enabled': true,
	'status_text_mode': 'default', # default, classic, and score
}

var save: Dictionary = {}
var save_file: FileAccess

func _ready() -> void:
	if FileAccess.file_exists('user://Settings.json'):
		save_file = FileAccess.open('user://Settings.json', FileAccess.READ)
		var test_json_conv = JSON.new()
		test_json_conv.parse(save_file.get_as_text())
		save = test_json_conv.get_data()
	else:
		save_file = FileAccess.open('user://Settings.json', FileAccess.WRITE)
		save_file.store_line(JSON.stringify(og_save))
	
	for key in og_save.keys():
		if not save.has(key):
			save[key] = og_save[key]
	
	save_file.close()
	save_data()
	
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if (save['vsync']) else DisplayServer.VSYNC_DISABLED)
	setup_binds()

func get_data(key: String):
	return save[key]

func set_data(key: String, value) -> void:
	save[key] = value
	save_data()

func save_data() -> void:
	save_file = FileAccess.open('user://Settings.json', FileAccess.WRITE)
	save_file.store_line(JSON.new().stringify(save))
	save_file.close()

var alt_keys: Dictionary = {
	1: ['up'],
	2: ['left', 'right'],
	3: ['left', 'up', 'right'],
	4: ['left', 'down', 'up', 'right'],
	5: ['left', 'down', 'end', 'up', 'right'],
}

func setup_binds() -> void:
	Input.set_use_accumulated_input(false)
	var binds = get_data('binds_' + str(Globals.key_count))
	
	for action_num in Globals.key_count:
		if action_num > binds.size() - 1:
			break
		
		var action = 'gameplay_' + str(action_num)
		var keys = InputMap.action_get_events(action)
		
		var new_event: InputEventKey = InputEventKey.new()
		# set key to the scancode of the key
		new_event.keycode = OS.find_keycode_from_string(binds[action_num].to_lower())
		
		if not keys.is_empty(): # error handling shit i forgot the cause of lmao
			InputMap.action_erase_events(action)
		else:
			InputMap.add_action(action)
		
		InputMap.action_add_event(action, new_event)
		
		if not alt_keys.has(Globals.key_count):
			continue
		
		var alt_event: InputEventKey = InputEventKey.new()
		alt_event.keycode = OS.find_keycode_from_string(
				alt_keys[Globals.key_count][action_num].to_lower())
		InputMap.action_add_event(action, alt_event)
