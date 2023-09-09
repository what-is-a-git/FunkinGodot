extends Node2D

var duration_left: float = 0.0
var intensity: float = 0.0
var camera: Camera2D

func _ready():
	randomize()

func shake(_intensity: float, _duration: float):
	camera = $"../Camera3D"
	
	duration_left = _duration
	intensity = _intensity

func _physics_process(delta):
	if duration_left > 0:
		duration_left -= delta
		
		if duration_left <= 0:
			camera.offset = Vector2(0,0)
		
		if duration_left > 0:
			camera.offset.x = randf_range(-intensity * 1280, intensity * 1280) * (1 + (1 - camera.zoom.x))
			camera.offset.y = randf_range(-intensity * 720, intensity * 720) * (1 + (1 - camera.zoom.y))
