extends TabContainer

@onready var p1 = $"Art/Player 1"
@onready var p2 = $"Art/Player 2"
@onready var gf = $"Art/GF"

@onready var stage = $"Art/Stage"

@onready var ui_skin = $"Art/UI Skin"

@onready var key_count = $"Chart/Key Count"

@onready var charter = $"../"
@onready var grid = charter.get_node("Grid")

var characters = []
var stages = []
var ui_skins = []

func _ready():
	read_chars()
	read_stages()
	read_skins()
	
	if not "keyCount" in charter.song:
		charter.song["keyCount"] = Globals.key_count
	
	key_count.text = str(charter.song["keyCount"])

func read_stages():
	var dir := DirAccess.open("res://Scenes/Stages/")
	
	dir.list_dir_begin() # TODOConverter3To4 fill missing arguments https://github.com/godotengine/godot/pull/40547
	
	stages = []
	
	while true:
		var file = dir.get_next()
		
		if file == "":
			break
		elif file.ends_with(".tscn"):
			stages.append(file.replace(".tscn", ""))
	
	for stage_name in stages:
		stage.add_item(stage_name)
	
	if "stage" in charter.song:
		if stages.find(charter.song["stage"]) != -1:
			stage.selected = stages.find(charter.song["stage"])
	else:
		if stages.find("stage") != -1:
			stage.selected = stages.find("stage")

func read_chars():
	var dir := DirAccess.open("res://Scenes/Characters/")
	dir.list_dir_begin() # TODOConverter3To4 fill missing arguments https://github.com/godotengine/godot/pull/40547
	
	characters = []
	
	while true:
		var file = dir.get_next()
		
		if file == "":
			break
		elif file.ends_with(".tscn"):
			characters.append(file.replace(".tscn", ""))
	
	for character in characters:
		p1.add_item(character)
		p2.add_item(character)
		gf.add_item(character)
	
	if characters.find(charter.song["player1"]) != -1:
		p1.selected = characters.find(charter.song["player1"])
	if characters.find(charter.song["player2"]) != -1:
		p2.selected = characters.find(charter.song["player2"])
	if "gf" in charter.song:
		if characters.find(charter.song["gf"]) != -1:
			gf.selected = characters.find(charter.song["gf"])

func read_skins():
	var dir := DirAccess.open("res://Scenes/UI Skins/")
	dir.list_dir_begin() # TODOConverter3To4 fill missing arguments https://github.com/godotengine/godot/pull/40547
	
	ui_skins = []
	
	while true:
		var file = dir.get_next()
		
		if file == "":
			break
		elif file.ends_with(".tscn"):
			ui_skins.append(file.replace(".tscn", ""))
	
	for skin in ui_skins:
		ui_skin.add_item(skin)
	
	if ui_skins.find(charter.song["ui_skin"]) != -1:
		ui_skin.selected = ui_skins.find(charter.song["ui_skin"])

func update_stuff(_index = 0):
	charter.song["player1"] = characters[p1.selected]
	charter.song["player2"] = characters[p2.selected]
	charter.song["gf"] = characters[gf.selected]
	charter.song["stage"] = stages[stage.selected]
	
	if len(ui_skins) > 0:
		charter.song["ui_skin"] = ui_skins[ui_skin.selected]
	
	if load("res://Scenes/Gameplay/Strums/" + key_count.text + ".tscn") != null:
		charter.song["keyCount"] = int(key_count.text)

func change_section_player(is_pointing:bool):
	if charter:
		charter.song.notes[charter.selected_section].mustHitSection = is_pointing
		grid.update()
