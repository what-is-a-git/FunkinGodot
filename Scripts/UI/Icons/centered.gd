extends IconBounce

# the shit you modify :D
func on_process(delta: float) -> void:
	iconP1.scale.x = lerp(iconP1.scale.x, 1.0, v(0.09, delta))
	iconP2.scale.x = lerp(iconP2.scale.x, 1.0, v(0.09, delta))
	
	iconP1.scale.y = lerp(iconP1.scale.y, 1.0, v(0.09, delta))
	iconP2.scale.y = lerp(iconP2.scale.y, 1.0, v(0.09, delta))

func beat_hit() -> void:
	iconP1.scale.x += icon_beat_scale
	iconP2.scale.x += icon_beat_scale
	
	if iconP1.scale.x > 1 + icon_beat_scale:
		iconP1.scale.x = 1 + icon_beat_scale
	if iconP2.scale.x > 1 + icon_beat_scale:
		iconP2.scale.x = 1 + icon_beat_scale
	
	iconP1.scale.y += icon_beat_scale
	iconP2.scale.y += icon_beat_scale
	
	if iconP1.scale.y > 1 + icon_beat_scale:
		iconP1.scale.y = 1 + icon_beat_scale
	if iconP2.scale.y > 1 + icon_beat_scale:
		iconP2.scale.y = 1 + icon_beat_scale
