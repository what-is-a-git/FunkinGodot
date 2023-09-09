extends Node

@onready var bf:Node2D = $"../".bf

func _ready():
	Conductor.connect("beat_hit", Callable(self, "beat_hit"))

func beat_hit():
	if Conductor.curBeat % 8 == 7 and bf:
		bf.timer = 0
		bf.play_animation("hey", true)
