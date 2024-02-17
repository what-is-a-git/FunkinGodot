extends FunkinScript


func _on_beat_hit(beat: int) -> void:
	if not is_instance_valid(player):
		return
	
	if beat % 8 == 7:
		player.play_anim('hey', true, true)
