class_name StoryMenuProp extends Node2D


@export var dance_steps: PackedStringArray = ['idle']

@onready var animation_player: AnimationPlayer = %animation_player

var dance_step: int = 0
var last_animation: StringName


func play_anim(animation: StringName, force: bool = false) -> void:
	if not is_instance_valid(animation_player):
		return
	if not animation_player.has_animation(animation):
		return
	if animation_player.current_animation == animation and not force:
		return
	
	last_animation = animation
	animation_player.play(animation)


func dance(force: bool = false) -> void:
	dance_step = wrapi(dance_step + 1, 0, dance_steps.size())
	play_anim(dance_steps[dance_step], force)
