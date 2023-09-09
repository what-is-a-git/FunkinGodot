extends Node2D

var started: bool = false
@onready var camera: Camera2D = $Camera
@onready var title_text: Node2D = $'Title Text'

func _ready() -> void:
	await get_tree().create_timer(0.1).timeout
	
	Discord.update_presence("On the Title Screen")
	
	Conductor.change_bpm(102)
	AudioHandler.play_audio("Title Music")
	
	started = true
	
	Conductor.connect('beat_hit', Callable(self, 'on_beat_hit'))

func _process(delta: float) -> void:
	if is_instance_valid(title_text):
		camera.zoom = lerp(camera.zoom, Vector2.ONE, delta * 5.0)
	elif is_instance_valid(camera):
		camera.queue_free()
	
	if Input.is_action_just_pressed("ui_back"):
		get_tree().quit()
	
	if started:
		Conductor.songPosition += delta * 1000

func on_beat_hit() -> void:
	if is_instance_valid(title_text):
		camera.zoom += Vector2(0.05, 0.05)
