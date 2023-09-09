extends Node

@onready var gf = $"../".gf

func _ready() -> void:
	Conductor.connect("beat_hit", Callable(self, "beat_hit"))

func beat_hit():
	var cur_beat = Conductor.curBeat
	
	if gf:
		if (cur_beat >= 32 and cur_beat <= 96) or (cur_beat >= 128 and cur_beat <= 192):
			if cur_beat % 4 == 2:
				gf.play_animation("cheer", true)
				gf.modulate.a = 1
