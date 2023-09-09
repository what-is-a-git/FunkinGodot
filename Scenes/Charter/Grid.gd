extends Node2D

@export var rows: int = 16
@export var columns: int = 8

@export var grid_size: int = 40

var selected_x = 0
var selected_y:float = 0.0

@onready var charter = $"../"
@onready var note_template = $"../Notes/Template"

@onready var line_1 = $"Black Line 1"
@onready var line_2 = $"Black Line 2"

@onready var player = $"Player"
@onready var enemy = $"Enemy"

@onready var notes = $"../Notes"

@onready var hitsound = $"../Hitsound"

@onready var dialog = $"../FileDialog"

@onready var line = $Line
@onready var selected = $Selected

var note_snap = 16

var current_note:Array

func _ready():
	note_template.modulate.a = 1
	
	notes.remove_child(note_template)
	
	charter.connect("changed_section", Callable(self, "load_section"))
	
	load_section()

func load_section():
	for note in notes.get_children():
		note.free()
	
	if not charter.selected_section in charter.song.notes:
		charter.song.notes.append({
			"sectionNotes": [],
			"lengthInSteps": 16,
			"mustHitSection": charter.song.notes[len(charter.song.notes) - 1].mustHitSection
		})
	
	for note in charter.song.notes[charter.selected_section].sectionNotes:
		spawn_note(note[1] + 1, time_to_y(note[0] - section_start_time()), time_to_y(note[0] - section_start_time()), float(note[2]))
	
	queue_redraw()
	
func _draw():
	var dark = false
	
	for x in columns + 1:
		dark = !dark
		
		if (x * grid_size) + position.x > 1280:
			break
		if (x * grid_size) + position.x < 0 - grid_size:
			continue
		
		for y in rows:
			draw_box(x,y,dark)
			
			dark = !dark
			
			if (y * grid_size) + position.y > 720:
				break
			if (y * grid_size) + position.y < 0 - grid_size:
				continue
	
	line_1.position.x = grid_size
	line_1.size.y = rows * grid_size
	
	line_2.position.x = grid_size * ((columns / 2) + 1)
	line_2.size.y = rows * grid_size
	
	if charter:
		if charter.song.notes[charter.selected_section].mustHitSection:
			player.position.x = grid_size
			enemy.position.x = grid_size * ((columns / 2) + 1)
		else:
			player.position.x = grid_size * ((columns / 2) + 1)
			enemy.position.x = grid_size
	
	line.size.x = (columns + 1) * grid_size

func _physics_process(_delta):
	for note in notes.get_children():
		if y_to_time(note.position.y) + (Conductor.timeBetweenSteps / 4) <= Conductor.songPosition - section_start_time():
			if note.modulate.a == 1 and AudioHandler.get_node("Inst").playing:
				hitsound.play(0)
			
			note.modulate.a = 0.5
		else:
			note.modulate.a = 1

func _process(delta):
	if "keyCount" in charter.song:
		columns = charter.song["keyCount"] * 2
	
	line.position.y = time_to_y(Conductor.songPosition - section_start_time())
	
	var prev_selected_x = selected_x
	var prev_selected_y = selected_y
	
	var mouse_pos = get_global_mouse_position()
	mouse_pos.x -= position.x
	mouse_pos.y -= position.y
	
	selected_x = floor(mouse_pos.x / grid_size)
	selected_y = floor(mouse_pos.y / grid_size)
	
	var cool_grid = grid_size / (note_snap / 16.0)
	
	if Input.is_action_pressed("ui_shift"):
		selected.position = Vector2(selected_x * grid_size, mouse_pos.y)
	else:
		selected.position = Vector2(selected_x * grid_size, floor(mouse_pos.y / cool_grid) * cool_grid)
	
	if prev_selected_x != selected_x or prev_selected_y != selected_y:
		queue_redraw()
	
	if Input.is_action_just_pressed("mouse_left") and not dialog.visible:
		if selected_x >= 0 and selected_x <= columns:
			if selected_y >= 0 and selected_y < rows:
				var note = add_note(selected_x, selected_y)
				
				if note:
					current_note = note
	
	if Input.is_action_just_pressed("ui_confirm"):
		AudioHandler.get_node("Inst").volume_db = 0
		AudioHandler.get_node("Voices").volume_db = 0
		
		Globals.song = charter.song
		Scenes.switch_scene("Gameplay")
		Globals.do_cutscenes = false
	
	if Input.is_action_just_pressed("charting_sustain"):
		if current_note:
			if current_note[2] <= 0:
				current_note[2] += Conductor.timeBetweenSteps
			else:
				if Input.is_action_pressed("ui_shift"):
					current_note[2] += Conductor.timeBetweenSteps
				else:
					current_note[2] += Conductor.timeBetweenSteps / 2
			
			load_section()
			_physics_process(0)
	
	if Input.is_action_just_pressed("charting_sustain_down"):
		if current_note:
			current_note[2] -= Conductor.timeBetweenSteps / 2
			
			if current_note[2] < 0:
				current_note[2] = 0
			
			load_section()
			_physics_process(0)

func add_note(x, y):
	var mouse_pos = get_global_mouse_position()
	mouse_pos.x -= position.x
	mouse_pos.y -= position.y
	
	for note in notes.get_children():
		if selected_x * grid_size == note.position.x:
			if mouse_pos.y >= note.position.y and mouse_pos.y <= note.position.y + grid_size:
				for note_object in charter.song.notes[charter.selected_section].sectionNotes:
					if note_object[1] == int(x - 1):
						if int(note_object[0]) == int(y_to_time(note.position.y) + section_start_time()):
							charter.song.notes[charter.selected_section].sectionNotes.erase(note_object)
				
				note.queue_free()
				return
	
	var note = spawn_note(x, y, null, 0)
	if note:
		note.modulate.a = 0.5
	
	var strum_time = y_to_time(selected.position.y) + section_start_time()
	var note_data = int(x - 1)
	var note_length = 0.0
	
	charter.song.notes[charter.selected_section].sectionNotes.append([strum_time, note_data, note_length])
	
	return charter.song.notes[charter.selected_section].sectionNotes[len(charter.song.notes[charter.selected_section].sectionNotes) - 1]

func spawn_note(x, y, custom_y = null, sustain_length:float = 0.0):
	if custom_y == null:
		custom_y = selected.position.y
	
	var mouse_pos = get_global_mouse_position()
	mouse_pos.x -= position.x
	mouse_pos.y -= position.y
	
	var new_note = note_template.duplicate()
	new_note.position = Vector2(x * grid_size, custom_y)
	
	var key_count:int = 4
	
	if "keyCount" in charter.song:
		key_count = int(charter.song["keyCount"])
	
	var anim_spr = new_note.get_node("AnimatedSprite2D")
	anim_spr.play(Globals.int_to_dir(int(x - 1) % key_count, key_count))
	new_note.scale.x = 40.0 / anim_spr.sprite_frames.get_frame_texture(anim_spr.animation, anim_spr.frame).get_width()
	new_note.scale.y = 40.0 / anim_spr.sprite_frames.get_frame_texture(anim_spr.animation, anim_spr.frame).get_height()
	
	if sustain_length > 0:
		var sustain = new_note.get_node("Sustain")
		sustain.visible = true
		sustain.size.y = floor(remap(sustain_length, 0, Conductor.timeBetweenSteps * 16, 0, rows * grid_size)) / new_note.scale.y
	
	notes.add_child(new_note)
	return new_note

func draw_box(x, y, is_dark):
	var cool_color = Color(0.9, 0.9, 0.9)
	
	if is_dark:
		cool_color = Color(0.835, 0.835, 0.835)
	
	draw_rect(Rect2(Vector2(x * grid_size, y * grid_size), Vector2(grid_size, grid_size)), cool_color, true)

func y_to_time(y):
	return remap(y + grid_size, position.y, position.y + (rows * grid_size), 0, 16 * Conductor.timeBetweenSteps)

func time_to_y(time):
	return remap(time - Conductor.timeBetweenSteps, 0, 16 * Conductor.timeBetweenSteps, position.y, position.y + (rows * grid_size))

func section_start_time(section = null):
	if section == null:
		section = charter.selected_section
	
	var coolPos:float = 0.0
	
	var good_bpm = Conductor.bpm
	
	for i in section:
		if "changeBPM" in charter.song.notes[i]:
			if charter.song.notes[i]["changeBPM"] == true:
				good_bpm = charter.song.notes[i]["bpm"]
		
		coolPos += 4 * (1000 * (60 / good_bpm))
	
	return coolPos

func _input(event : InputEvent) -> void:
	if event is InputEventMouseButton:
		event as InputEventMouseButton
		if event.pressed:
			match event.button_index:
				MOUSE_BUTTON_WHEEL_UP:
					if Input.is_action_pressed("ui_shift"):
						Conductor.songPosition -= 100
					else:
						Conductor.songPosition -= 25
					
					if Conductor.songPosition < 0:
						Conductor.songPosition = 0
					
					if Conductor.songPosition < charter.section_start_time():
						charter.selected_section -= 1
						
						if charter.selected_section < 0:
							charter.selected_section = 0
						
						load_section()
				MOUSE_BUTTON_WHEEL_DOWN:
					if Input.is_action_pressed("ui_shift"):
						Conductor.songPosition += 100
					else:
						Conductor.songPosition += 25
					
					if Conductor.songPosition > charter.section_start_time() + (4 * (1000 * (60 / Conductor.bpm))):
						charter.selected_section += 1
						
						load_section()
