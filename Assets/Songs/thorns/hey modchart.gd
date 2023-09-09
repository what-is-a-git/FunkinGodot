extends Node

@onready var game = $"../"
@onready var bf = game.bf

func _ready() -> void:
	Conductor.connect("beat_hit", Callable(self, "beat_hit"))

func beat_hit():
	var cur_beat = Conductor.curBeat
	
	if bf:
		if (cur_beat >= 64 and cur_beat <= 96) or (cur_beat >= 159 and cur_beat <= 192) or (cur_beat >= 255 and cur_beat <= 288):
			if cur_beat % 4 == 1 or cur_beat % 4 == 3:
				bf.play_animation("hey", true)
				game.camera.zoom -= Vector2(0.05, 0.05)
				
				game.ui.scale += Vector2(0.025, 0.025)
				game.ui.offset += Vector2(-650 * 0.025, -400 * 0.025)
