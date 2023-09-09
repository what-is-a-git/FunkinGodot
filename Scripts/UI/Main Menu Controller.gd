extends Node

var selected: int = 0

var selected_menu: bool = false
var press_timer: float = 0.0

@onready var anim_player: AnimationPlayer = $'../1-0-2/BG/AnimationPlayer'
@onready var camera: Camera2D = $"../Camera"
@onready var version_text: Label = $'../UI/Version Text'

func _ready() -> void:
	if not AudioHandler.get_node("Title Music").playing:
		AudioHandler.play_audio("Title Music")
	
	version_text.text += '\nGodot v%s' % Engine.get_version_info().string
	
	change_item(0)

func _process(delta: float) -> void:
	if !selected_menu:
		if Input.is_action_just_pressed("ui_back"): Scenes.switch_scene("Title Screen")
		if Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("ui_down"):
			change_item(ceil(Input.get_axis("ui_up", "ui_down")))
		if Input.is_action_just_pressed("ui_accept"):
			selected_menu = true
			
			if Settings.get_data("flashingLights"):
				anim_player.play("blinking")
			
			for child in get_children():
				if child != get_child(selected):
					child.visible = false
			
			AudioHandler.play_audio("Confirm Sound")
	else:
		if Settings.get_data("flashingLights"):
			press_timer += delta
		else:
			press_timer = 1.1
	
	if press_timer > 1:
		match(get_child(selected).name.to_lower()):
			"freeplay":
				Scenes.switch_scene("Freeplay")
			"options":
				OptionsSideBar.returning_scene = 'Main Menu'
				Scenes.switch_scene("Options Menu")
			"mods":
				pass
				# Scenes.switch_scene("Mods Menu")
			"story mode":
				Scenes.switch_scene("Story Mode")
			_:
				print("NOT IMPLEMENTED YET DUMBIE")
		
		press_timer = 0
	
func change_item(amount: int = 0) -> void:
	var previous: int = selected
	selected += amount
	
	if selected < 0: selected = get_child_count() - 1
	if selected > get_child_count() - 1: selected = 0
	
	get_child(previous).get_node("AnimatedSprite2D").play("unselected")
	get_child(selected).get_node("AnimatedSprite2D").play("selected")
	
	AudioHandler.play_audio("Scroll Menu")
	
	if selected != 0:
		camera.position.y = get_child(selected).position.y - 25
	else:
		camera.position.y = get_child(selected).position.y
	
	Discord.update_presence("In the Main Menu", "Selecting " + get_child(selected).name)
