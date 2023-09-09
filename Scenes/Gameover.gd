extends Node2D

var death_character: Node2D
var pressed_enter: bool = false

@onready var camera: Camera2D = $Camera

func _ready() -> void:
	randomize()
	
	AudioHandler.stop_audio('Inst')
	AudioHandler.stop_audio('Voices')
	
	AudioHandler.play_audio('Gameover Death')
	
	var death_loaded: PackedScene = Globals.load_character(Globals.death_character_name, 'bf-dead')
	
	death_character = death_loaded.instantiate()
	death_character.position = Globals.death_character_pos
	death_character.play_animation('firstDeath')
	add_child(death_character)
	
	camera.position = Globals.death_character_cam
	
	get_tree().create_timer(2.375).connect('timeout', Callable(self, '_start_death_stuff'))

func _start_death_stuff() -> void:
	if !pressed_enter:
		death_character.play_animation('deathLoop')
		AudioHandler.play_audio('Gameover Music')

func _process(delta: float) -> void:
	if not camera.position_smoothing_enabled:
		camera.position_smoothing_enabled = true
	
	if Input.is_action_just_pressed('ui_back'):
		Scenes.switch_scene('Freeplay' if Globals.freeplay else 'Story Mode')
	
	if Input.is_action_just_pressed('ui_accept') and !pressed_enter:
		pressed_enter = true
		
		AudioHandler.stop_audio('Gameover Music')
		AudioHandler.play_audio('Gameover Retry')
		
		death_character.play_animation('retry')
		
		await get_tree().create_timer(1.375).timeout
		
		Scenes.switch_scene('Gameplay')
		Globals.do_cutscenes = false
	
	if not line.playing:
		AudioHandler.get_node('Gameover Music').volume_db = -4
	
	var death_sprite: AnimatedSprite2D = death_character.anim_sprite
	
	if not death_sprite:
		return
	
	if death_sprite.frame >= death_sprite.sprite_frames.get_frame_count(death_sprite.animation) - 1 or \
			(death_character.anim_sprite.frame >= 12 and death_sprite.animation == 'firstDeath'):
		camera.position = death_character.position + death_character.camOffset
		AudioHandler.get_node('Gameover Music').volume_db = -8
