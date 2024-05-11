class_name Gameover extends Node2D


static var character_position: Vector2 = Vector2.ZERO
static var character_path: String = 'res://scenes/game/assets/characters/face.tscn'
static var camera_zoom: Vector2 = Vector2.ONE
static var camera_position: Vector2 = Vector2.ZERO

@onready var camera: Camera2D = %camera
@onready var music_player: AudioStreamPlayer = %music
@onready var on_death: AudioStreamPlayer = %on_death
@onready var retry: AudioStreamPlayer = %retry
@onready var secret: CanvasLayer = $secret

var character: Character
var active: bool = true


func _ready() -> void:
	randomize()
	active = true
	
	# 1 in a million chance!
	if randi_range(1, 1000) == 273:
		active = false
		secret.get_node('player').play()
		return
	else:
		secret.free()
	
	Conductor.reset()
	Conductor.bpm = 100.0
	Conductor.target_audio = music_player
	
	camera.zoom = camera_zoom
	camera.global_position = camera_position
	camera.position_smoothing_enabled = false
	get_tree().create_timer(0.5).timeout.connect(func():
		camera.position_smoothing_enabled = true
		camera.position = character.position + character._camera_offset.position)
	
	character = load(character_path).instantiate()
	add_child(character)
	character.global_position = character_position
	character.play_anim(&'death')
	character.animation_finished.connect(_on_animation_finished)
	on_death.play()


func _input(event: InputEvent) -> void:
	if event.is_echo():
		return
	if not event.is_pressed():
		return
	if not active:
		return
	
	if event.is_action('ui_cancel'):
		active = false
		GlobalAudio.get_player('MENU/CANCEL').play()
		
		match Game.mode:
			Game.PlayMode.FREEPLAY:
				SceneManager.switch_to('scenes/menus/freeplay_menu.tscn')
			_:
				SceneManager.switch_to('scenes/menus/title_screen.tscn')
	if event.is_action('ui_accept'):
		active = false
		character.play_anim(&'retry')
		music_player.stop()
		retry.play()
		get_tree().create_timer(0.7).timeout.connect(func():
			var tween := create_tween()
			tween.tween_property(self, 'modulate:a', 0.0, 2.0)
			tween.tween_callback(func():
				SceneManager.switch_to('scenes/game/game.tscn')
			)
		)


func _on_animation_finished(animation: StringName) -> void:
	match animation:
		&'death':
			character.play_anim(&'loop')
			music_player.play()
