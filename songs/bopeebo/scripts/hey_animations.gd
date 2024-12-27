extends FunkinScript


func _on_beat_hit(beat: int) -> void:
	if not is_instance_valid(player):
		return
	# hacky fix for 1.0 but i'm not adding playanimation support yet :p
	if beat > 130:
		return
	
	if beat % 8 == 7:
		player.play_anim('hey', true, true)
