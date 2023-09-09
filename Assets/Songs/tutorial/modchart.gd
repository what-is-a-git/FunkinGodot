extends Node

@onready var bf:Node2D = $"../".bf
@onready var dad:Node2D = $"../".dad
@onready var gf:Node2D = $"../".gf

func _ready():
	Conductor.connect("beat_hit", Callable(self, "beat_hit"))

func beat_hit():
	if Conductor.curBeat > 16 and Conductor.curBeat < 48:
		if Conductor.curBeat % 16 == 15 and bf:
			bf = $"../".bf
			gf = $"../".gf
			dad = $"../".dad
			
			bf.timer = 0
			bf.play_animation("hey", true)
			
			if gf != dad:
				gf.timer = 0
				gf.play_animation("cheer", true)
			else:
				dad.timer = 0
				dad.play_animation("cheer", true)
