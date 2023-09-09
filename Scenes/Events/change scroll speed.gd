extends Event

var tween: Tween

func process_event(argument_1, argument_2) -> void:
	if is_instance_valid(tween) and tween.is_valid():
		tween.kill()
	
	if float(argument_2) <= 0:
		Globals.scroll_speed = float(argument_1) / Globals.song_multiplier
	else:
		tween = create_tween()
		tween.tween_property(Globals, 'scroll_speed', float(argument_1) / Globals.song_multiplier, float(argument_2) / Globals.song_multiplier)
