extends Node2D

@onready var info = $"Charting Info"

var song:Dictionary
var selected_section = 0

var playing:bool = false

var bpm_changes = []

signal changed_section

var ms_offsync_allowed:int = 20

var inst:AudioStreamPlayer
var voices:AudioStreamPlayer

@onready var grid = $Grid
@onready var file_dialog = $FileDialog

func _init():
	inst = AudioHandler.get_node("Inst")
	voices = AudioHandler.get_node("Voices")
	
	if OS.get_name().to_lower() == "windows":
		ms_offsync_allowed = 30 # because for some reason windows has weird syncing issues that i'm too stupid to fix properly
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	inst.pitch_scale = 1
	voices.pitch_scale = 1
	
	if Globals.song == null:
		var file := FileAccess.open(Paths.song_path(Globals.song_name, Globals.song_difficulty), FileAccess.READ)

		var test_json_conv = JSON.new()
		test_json_conv.parse(file.get_as_text())
		Globals.song = test_json_conv.get_data()["song"]
	
	song = Globals.song
	
	Conductor.songPosition = 0
	
	for section in song["notes"]:
		if "changeBPM" in section:
			if section["changeBPM"]:
				bpm_changes.append([section_start_time(song["notes"].find(section)), float(section["bpm"])])
	
	Conductor.change_bpm(float(song["bpm"]), bpm_changes)
	
	AudioHandler.stop_audio("Inst")
	AudioHandler.stop_audio("Voices")
	
	stop_next_frame = true

func _ready():
	AudioHandler.stop_audio("Inst")
	AudioHandler.stop_audio("Voices")
	
	stop_next_frame = true

var stop_next_frame:bool = false

func _physics_process(_delta):
	var inst_pos = (inst.get_playback_position() * 1000) + (AudioServer.get_time_since_last_mix() * 1000)
	inst_pos -= AudioServer.get_output_latency() * 1000
	
	if inst_pos > Conductor.songPosition - (AudioServer.get_output_latency() * 1000) + ms_offsync_allowed or inst_pos < Conductor.songPosition - (AudioServer.get_output_latency() * 1000) - ms_offsync_allowed:
		inst.seek(Conductor.songPosition / 1000)
		voices.seek(Conductor.songPosition / 1000)

func _process(delta):
	var prev_section = selected_section
	
	var changed_sections = false
	
	if Input.is_action_just_pressed("ui_left"):
		selected_section -= 1
		changed_sections = true
	if Input.is_action_just_pressed("ui_right"):
		selected_section += 1
		changed_sections = true
	
	if Input.is_action_just_pressed("ui_space"):
		playing = !playing
		
		if playing:
			inst.volume_db = 0
			voices.volume_db = 0
			
			AudioHandler.play_audio("Inst", Conductor.songPosition / 1000.0)
			
			if song["needsVoices"]:
				AudioHandler.play_audio("Voices", Conductor.songPosition / 1000.0)
		else:
			inst.volume_db = -80
			voices.volume_db = -80
			
			AudioHandler.stop_audio("Inst")
			AudioHandler.stop_audio("Voices")
	
	if Conductor.songPosition / 1000 >= inst.stream.get_length():
		playing = false
		
		selected_section = 0
		
		Conductor.songPosition = 0
		
		inst.seek(0)
		voices.seek(0)
		
		grid.load_section()
		grid.update()
	
	if !playing and (inst.playing or voices.playing):
		inst.seek(0)
		voices.seek(0)
		
		inst.volume_db = -80
		voices.volume_db = -80
		
		inst.playing = false
		voices.playing = false
	
	if playing:
		Conductor.songPosition += delta * 1000
		
		if not changed_sections and Conductor.songPosition >= section_start_time() + (4 * (1000 * (60 / Conductor.bpm))):
			selected_section += 1
			changed_sections = true
	
	if changed_sections:
		if selected_section < 0:
			selected_section = 0
		if selected_section > len(song.notes):
			song.notes.append({
				"lengthInSteps": 16,
				"bpm": song.bpm,
				"changeBPM": false,
				"mustHitSection": song.notes[selected_section - 1].mustHitSection,
				"sectionNotes": [],
				"altAnim": false
			})
		
		emit_signal("changed_section")
		
		Conductor.songPosition = section_start_time()
		
		if not "changeBPM" in song.notes[selected_section]:
			song.notes[selected_section].changeBPM = false
		
		if not "bpm" in song.notes[selected_section]:
			song.notes[selected_section].bpm = song.bpm
		
		bpm_checkbox.button_pressed = song.notes[selected_section].changeBPM
		bpm_box.text = str(song.notes[selected_section].bpm)
	
	info.text = "Song Position: " + str(round(inst.get_playback_position() * 100) / 100) + " / " + str(round(inst.stream.get_length() * 100) / 100)
	info.text += "\nBeat: " + str(Conductor.curBeat)
	info.text += "\nStep: " + str(Conductor.curStep)
	info.text += "\nSection: " + str(selected_section)

func section_start_time(section = null):
	if section == null:
		section = selected_section
	
	var coolPos:float = 0.0
	
	var good_bpm = song["bpm"]
	
	for i in section:
		if "changeBPM" in song.notes[i]:
			if song.notes[i]["changeBPM"] == true and song.notes[i]["bpm"] > 0:
				good_bpm = song.notes[i]["bpm"]
		
		coolPos += 4.0 * (1000.0 * (60.0 / good_bpm))
	
	return coolPos

func save_file():
	file_dialog.popup_centered()

func file_saved(path):
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_line(JSON.stringify({"song": song}))

func reset_chart():
	selected_section = 0
	
	song.notes.clear()
	
	song.notes.append({
		"lengthInSteps": 16,
		"bpm": song.bpm,
		"changeBPM": false,
		"mustHitSection": true,
		"sectionNotes": [],
		"altAnim": false
	})
	
	grid.load_section()

func reset_section():
	song.notes[selected_section].sectionNotes.clear()
	
	grid.load_section()

func clone_section(section:int = 0):
	if song.notes[section]:
		for note in song.notes[section].sectionNotes:
			var data = []
			
			for i in len(note):
				data.append(note[i])
			
			data[0] -= section_start_time(section)
			data[0] += section_start_time()
			
			song.notes[selected_section].sectionNotes.append(data)
		
		grid.load_section()

@onready var bpm_box = $"TabBar/Section/BPM"
@onready var bpm_checkbox = $"TabBar/Section/Change BPM"

func change_bpm(value: bool = true):
	song.notes[selected_section].changeBPM = value
	song.notes[selected_section].bpm = float(bpm_box.text)
