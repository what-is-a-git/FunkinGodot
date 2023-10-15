class_name Strum extends Node2D

@export var direction: String = 'left'
@export var note_data: int = 0

@export var enemy_strum: bool = false

@onready var animated_sprite = $AnimatedSprite2D
@onready var start_global_pos: Vector2

@onready var opponent_note_glow: bool = Settings.get_data("opponent_note_glow")
@onready var bot: bool = Settings.get_data("bot")

var animation: String

func _ready() -> void:
	play_animation("static")

func play_animation(anim, force = true):
	if force or animated_sprite.frame == animated_sprite.frames.get_frame_count(animated_sprite.animation):
		animation = anim
		animated_sprite.stop()
		
		var funny = direction
		
		if anim == "static":
			funny = funny.replace("2", "")
		
		animated_sprite.play(funny + " " + anim)
		animated_sprite.frame = 0

func reset_to_static():
	if animated_sprite.animation == "static":
		return
	if (enemy_strum and opponent_note_glow) or (!enemy_strum and bot):
		play_animation("static")
