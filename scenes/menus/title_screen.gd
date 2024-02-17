extends Node2D


@onready var girlfriend_animation: AnimationPlayer = $girlfriend/animation_player
var dance_left: bool = false
var active: bool = true


func _ready() -> void:
	if not GlobalAudio.get_player('MUSIC').playing:
		GlobalAudio.get_player('MUSIC').play()
		Conductor.reset()
		Conductor.bpm = 102.0
		Conductor.target_audio = GlobalAudio.get_player('MUSIC')
	
	Conductor.beat_hit.connect(_on_beat_hit)
	_on_beat_hit(0)


func _on_beat_hit(_beat: int) -> void:
	dance_left = not dance_left
	girlfriend_animation.play('dance_left' if dance_left else 'dance_right')


func _input(event: InputEvent) -> void:
	if not active:
		return
	if event.is_action('ui_accept') and event.is_action_pressed('ui_accept'):
		active = false
		SceneManager.switch_to('scenes/menus/freeplay_menu.tscn')
