extends AnimatedSprite

func _ready():
	Conductor.connect("beat_hit", Callable(self, "dance"))

func dance():
	if frame >= sprite_frames.get_frame_count(animation) - 1 or !playing:
		frame = 0
		stop()
		play("idle")
