class_name Gameover extends Node2D


static var character_position: Vector2 = Vector2.ZERO
static var character_path: String = 'res://scenes/game/assets/characters/face.tscn'
static var camera_zoom: Vector2 = Vector2.ONE
static var camera_position: Vector2 = Vector2.ZERO

@onready var camera: Camera2D = %camera

var character: Character


func _ready() -> void:
	camera.global_position = camera_position
	camera.position_smoothing_enabled = true
	(func():
		camera.position = character.position + character._camera_offset.position
	).call_deferred()
	
	character = load(character_path).instantiate()
	add_child(character)
	character.global_position = character_position


func _input(event: InputEvent) -> void:
	if event.is_echo():
		return
	if not event.is_pressed():
		return
	
	if event.is_action('ui_cancel'):
		GlobalAudio.get_player('MENU/CANCEL').play()
		
		match Game.mode:
			Game.PlayMode.FREEPLAY:
				SceneManager.switch_to('scenes/menus/freeplay_menu.tscn')
			_:
				SceneManager.switch_to('scenes/menus/title_screen.tscn')
