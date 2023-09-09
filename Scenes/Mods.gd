extends Node2D

@onready var template = $Template

var selected = 0

@onready var install_a_mod = $"../CanvasLayer/Install a mod!"

@onready var camera = $"../Camera2D"

func _ready():
	get_tree().connect("files_dropped", Callable(self, "_getDroppedFilesPath"))
	
	ModLoader.load_mods()
	
	var index = 0
	
	remove_child(template)
	
	for mod in ModLoader.mods:
		var newMod = template.duplicate()
		newMod.visible = true
		newMod.text = mod.to_upper()
		newMod.name = mod
		newMod.position.y = 38 + (113 * index)
		add_child(newMod)
		
		index += 1
	
	if len(ModLoader.mods) < 1:
		install_a_mod.visible = true
		
		Discord.update_presence("In the Mods Menu", "No mod selected!")
	else:
		change_item(0)

func _process(delta):
	if Input.is_action_just_pressed("ui_shift"):
		OS.shell_open(str("file://" + OS.get_user_data_dir() + "/Mods/"))
	if Input.is_action_just_pressed("ui_back"):
		ModLoader.load_mods()
		Scenes.switch_scene("Main Menu")
	if Input.is_action_just_pressed("ui_up"):
		change_item(-1)
	if Input.is_action_just_pressed("ui_down"):
		change_item(1)
	if Input.is_action_just_pressed("ui_accept") and len(get_children()) > 0:
		var active = Settings.get_data("active_mods")
		
		if active.has(get_children()[selected].name):
			active.erase(get_children()[selected].name)
		else:
			active.append(get_children()[selected].name)
		
		Settings.set_data("active_mods", active)
		
		change_item(0)

func change_item(amount):
	selected += amount
	
	if selected < 0:
		selected = len(get_children()) - 1
	if selected > len(get_children()) - 1:
		selected = 0
	
	AudioHandler.play_audio("Scroll Menu")
	
	var active = Settings.get_data("active_mods")
	
	for child in get_children():
		if active.has(child.name):
			child.modulate.a = 1
		else:
			child.modulate.a = 0.5
	
	if len(ModLoader.mods) > 0:
		camera.position.y = get_children()[selected].position.y
	
	if get_child_count() > 0:
		Discord.update_presence("In the Mods Menu", "Selecting " + get_children()[selected].name)

func _getDroppedFilesPath(files:PackedStringArray, screen:int) -> void:
	var mod_index = 0
	
	for file in files:
		var cool_file = File.new()
		cool_file.open(file, File.READ)
		
		var funny_array = cool_file.get_path_absolute().split("/", true)
		
		var new_dir = DirAccess.new()
		new_dir.copy(file, "user://Mods/" + funny_array[len(funny_array) - 1])
	
	Scenes.switch_scene("Mods Menu")
