extends Node

@onready var dad = $"../".dad

@onready var camera: Camera2D = $"../".camera
@onready var shake = $Shaker

func _ready():
	Conductor.connect("step_hit", Callable(self, "step_hit"))
	shake.camera = camera

func step_hit():
	match(Conductor.curStep):
		60, 444, 524, 540, 541, 829:
			if dad:
				dad.timer = 0
				dad.play_animation("ugh")
				
				shake.shake(0.01, Conductor.timeBetweenSteps / 1000.0)
				camera.zoom += Vector2(0.025, 0.025)
