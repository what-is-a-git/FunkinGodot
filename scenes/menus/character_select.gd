extends Node2D


@onready var CHARACTER_SELECT_INTRO = load('res://resources/music/menus/character_select_intro.ogg')
@onready var CHARACTER_SELECT = load('res://resources/music/menus/character_select.ogg')

@onready var dipshit_blur: AnimatedSprite = %dipshit_blur
@onready var dipshit_backing: AnimatedSprite = %dipshit_backing
@onready var choose_dipshit: Sprite2D = %choose_dipshit

@onready var spectator: AnimateSymbol = %spectator
var spectator_anim: AnimationPlayer

@onready var player: AnimateSymbol = %player
var player_anim: AnimationPlayer

@onready var speakers: AnimateSymbol = $speakers/sprite

@onready var music: AudioStreamPlayer = %music

var dipshit_tween: Tween


func _ready() -> void:
	Conductor.reset()
	Conductor.target_audio = music
	Conductor.tempo = 90.0
	Conductor.beat_hit.connect(_on_beat_hit)
	music.stream = CHARACTER_SELECT_INTRO
	music.play()
	
	dipshit_tween = create_tween().set_trans(Tween.TRANS_EXPO)\
			.set_ease(Tween.EASE_OUT).set_parallel()
	dipshit_blur.position.y += 220.0
	dipshit_tween.tween_property(dipshit_blur, ^'position:y', 
			dipshit_blur.position.y - 220.0, 1.2)
	
	dipshit_backing.position.y += 210.0
	dipshit_tween.tween_property(dipshit_backing, ^'position:y', 
			dipshit_backing.position.y - 210.0, 1.1)
	
	choose_dipshit.position.y += 200.0
	dipshit_tween.tween_property(choose_dipshit, ^'position:y', 
			choose_dipshit.position.y - 200.0, 1.0)
	
	spectator_anim = spectator.get_node(^'animation_player')
	spectator_anim.play(&'enter')
	player_anim = player.get_node(^'animation_player')
	player_anim.play(&'enter')


func _on_beat_hit(beat: int) -> void:
	player_anim.play(&'idle')
	speakers.frame = 0
	speakers.playing = true


func _on_music_finished() -> void:
	if music.stream != CHARACTER_SELECT:
		music.stream = CHARACTER_SELECT
	
	Conductor.reset()
	Conductor.target_audio = music
	Conductor.tempo = 90.0
	music.play()
