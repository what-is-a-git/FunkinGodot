extends Node


@onready var game: Gameplay = get_parent()
@onready var bf: Character = game.bf


func _ready() -> void:
	Conductor.connect("beat_hit", Callable(self, "beat_hit"))


func beat_hit() -> void:
	var cur_beat := Conductor.curBeat
	
	if game.bf:
		return
	
	if (cur_beat >= 64 and cur_beat <= 96) or (cur_beat >= 159 and cur_beat <= 192) or (cur_beat >= 255 and cur_beat <= 288):
		if cur_beat % 4 == 1 or cur_beat % 4 == 3:
			bf.play_animation('hey', true)
			game.camera.zoom += Vector2(0.05, 0.05)
			game.ui_layer.scale += Vector2(0.025, 0.025)
