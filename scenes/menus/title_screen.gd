extends Node2D


@onready var girlfriend_animation: AnimationPlayer = $girlfriend/animation_player
var dance_left: bool = false


func _ready() -> void:
	if not GlobalAudio.get_player('MUSIC').playing:
		GlobalAudio.get_player('MUSIC').play()
		Conductor.reset()
		Conductor.bpm = 102.0
		Conductor.target_audio = GlobalAudio.get_player('MUSIC')
	
	Conductor.beat_hit.connect(_on_beat_hit)
	_on_beat_hit(0)


func _process(delta: float) -> void:
	if Input.is_action_just_pressed('menu_accept'):
		SceneManager.switch_to('scenes/game/game.tscn')


func _on_beat_hit(_beat: int) -> void:
	dance_left = not dance_left
	girlfriend_animation.play('dance_left' if dance_left else 'dance_right')
