extends Node

@onready var camera = $"../Camera"
@onready var ui = $"../UI"

func _ready():
	Conductor.connect("beat_hit", Callable(self, "beat_hit"))

func beat_hit():
	if Conductor.curBeat >= 168 and Conductor.curBeat < 200:
		camera.zoom += Vector2(0.015, 0.015)
		ui.scale += Vector2(0.03, 0.03)
		ui.offset += Vector2(-22.5, -15)
