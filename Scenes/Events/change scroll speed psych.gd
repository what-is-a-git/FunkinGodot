extends Event

var tween: Tween

func process_event(argument_1, argument_2) -> void:
	var speed: float = (Globals.song.speed * float(argument_1)) / Globals.song_multiplier
	
	if float(argument_2) <= 0:
		Globals.scroll_speed = speed
	else:
		if is_instance_valid(tween) and tween.is_valid():
			tween.kill()
		
		tween = create_tween()
		tween.tween_property(Globals, "scroll_speed", speed, float(argument_2) / Globals.song_multiplier)
