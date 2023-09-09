extends Node2D

@onready var notes = $Notes
@onready var bind_template = $"Binds/Bind Template"
@onready var binds = $Binds
@onready var bind_testing_text = $"Bind Test Text"

var current_notes:Node2D

var key_count = 4
var key_selected = 0

var selecting_key = false

var no_select_next_frame = false

var is_hovering = false

var testing_binds = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	binds.remove_child(bind_template)
	
	load_key_count(key_count)

func _process(_delta):
	if !testing_binds:
		if Input.is_action_just_pressed("ui_cancel") and !selecting_key:
			Scenes.switch_scene("Options Menu")
		elif Input.is_action_just_pressed("ui_cancel") and selecting_key:
			selecting_key = false
		
		if (Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_right")) and !selecting_key and !no_select_next_frame:
			var prev_key_count = key_count
			
			if Input.is_action_just_pressed("ui_left"):
				key_count -= 1
			if Input.is_action_just_pressed("ui_right"):
				key_count += 1
			
			key_count = clamp(key_count, 4, 10)
			
			if prev_key_count != key_count:
				if !load_key_count(key_count):
					key_count = prev_key_count
		
		var mouse_pos = get_global_mouse_position()
		
		if !selecting_key:
			is_hovering = false
			
			for i in current_notes.get_child_count():
				var key = current_notes.get_child(i)
				
				key.modulate.a = 1
				
				if mouse_pos.x > key.global_position.x - ((154 / 2) * current_notes.scale.x) and mouse_pos.x < key.global_position.x + ((154 / 2) * current_notes.scale.x):
					if mouse_pos.y > key.global_position.y - ((154 / 2) * current_notes.scale.y) and mouse_pos.y < key.global_position.y + ((154 / 2) * current_notes.scale.y):
						key_selected = i
						key.modulate.a = 0.5
						
						is_hovering = true
						
						if Input.is_action_just_pressed("ui_accept") and !selecting_key:
							selecting_key = true
		
		if selecting_key:
			current_notes.get_child(key_selected).modulate.a = 0.5
		else:
			if Input.is_action_just_pressed("ui_confirm"):
				testing_binds = true
				
				Globals.key_count = key_count
				Settings.setup_binds()
				
				bind_testing_text.text = "[ Press ENTER to stop testing binds. ]"
		
		if no_select_next_frame:
			no_select_next_frame = false
		
		for i in key_count:
			current_notes.get_child(i).play_animation("static")
	else:
		for i in key_count:
			if Input.is_action_just_pressed("gameplay_" + str(i)):
				current_notes.get_child(i).play_animation("press")
			elif Input.is_action_just_released("gameplay_" + str(i)):
				current_notes.get_child(i).play_animation("static")
		
		if Input.is_action_just_pressed("ui_confirm"):
			testing_binds = false
			
			bind_testing_text.text = "[ Press ENTER to test binds. ]"

func load_key_count(keys):
	var key_path = "res://Scenes/Gameplay/Strums/" + str(keys) + ".tscn"
	
	if ResourceLoader.exists(key_path):
		if notes.get_child_count() > 0:
			notes.get_child(0).queue_free()
		
		for i in binds.get_child_count():
			binds.get_child(i).queue_free()
		
		var new_keys = load(key_path).instantiate()
		new_keys.disabled = true
		
		current_notes = new_keys
		
		notes.add_child(new_keys)
		
		for i in new_keys.get_child_count():
			var new_bind = bind_template.duplicate()
			new_bind.name = str(i)
			new_bind.index = i
			new_bind.text = Settings.get_data("binds_" + str(keys))[i]
			new_bind.global_position = new_keys.get_child(i).global_position - Vector2(10, 20)
			
			binds.add_child(new_bind)
		
		return true
	else:
		return false

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if is_hovering:
			selecting_key = true
	
	if event is InputEventKey and event.pressed and selecting_key:
		if event.keycode != KEY_ESCAPE:
			var binds_data = Settings.get_data("binds_" + str(key_count))
			
			var key_data = OS.get_keycode_string(event.keycode).to_upper()
			
			if binds_data.has(key_data):
				var old_index = binds_data.find(key_data)
				binds_data[old_index] = binds_data[key_selected]
				binds.get_child(old_index).text = binds_data[old_index]
			
			binds_data[key_selected] = key_data
			
			Settings.set_data("binds_" + str(key_count), binds_data)
			
			binds.get_child(key_selected).text = binds_data[key_selected]
			
			selecting_key = false
			no_select_next_frame = true
			
			for i in current_notes.get_child_count():
				if i != key_selected:
					current_notes.get_child(i).modulate.a = 1
			
			Settings.setup_binds()
