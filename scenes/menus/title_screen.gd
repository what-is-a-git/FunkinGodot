extends Node2D


@export var swag_material: ShaderMaterial

@onready var girlfriend_animation: AnimationPlayer = $girlfriend/animation_player
@onready var logo_sprite: AnimatedSprite = $logo/sprite
@onready var enter_animation: AnimationPlayer = $enter/animation_player
@onready var flash: ColorRect = $flash

var dance_left: bool = false
var active: bool = true


func _ready() -> void:
	enter_animation.play('loop')
	
	if not GlobalAudio.get_player('MUSIC').playing:
		GlobalAudio.get_player('MUSIC').play()
		Conductor.reset()
		Conductor.bpm = 102.0
		Conductor.target_audio = GlobalAudio.get_player('MUSIC')
	
	Conductor.beat_hit.connect(_on_beat_hit)
	_on_beat_hit(0)


func _process(delta: float) -> void:
	if not is_instance_valid(swag_material):
		return
	
	var swag_axis: float = Input.get_axis('ui_left', 'ui_right')
	swag_material.set_shader_parameter('value', 
			swag_material.get_shader_parameter('value') + delta * 0.1 * swag_axis)


func _on_beat_hit(_beat: int) -> void:
	dance_left = not dance_left
	girlfriend_animation.play('dance_left' if dance_left else 'dance_right')
	logo_sprite.play('bump')
	logo_sprite.frame = 0


func _input(event: InputEvent) -> void:
	if not active:
		return
	if event.is_action('ui_accept') and event.is_action_pressed('ui_accept'):
		active = false
		GlobalAudio.get_player('MENU/CONFIRM').play()
		enter_animation.play('press')
		
		flash.color = Color.WHITE
		
		var tween := create_tween()
		tween.tween_property(flash, 'color:a', 0.0, 1.0)
		tween.tween_callback(SceneManager.switch_to.bind('scenes/menus/main_menu.tscn'))
