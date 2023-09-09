extends Cutscene

func _ready() -> void:
	camera.position = gf.position + Vector2(75, -350)
	
	bf.play_animation("hey", true)
	
	await get_tree().create_timer(0.5).timeout
	
	dad.play_animation("singLEFT", true)
	gf.play_animation("scared", true)
	
	var tween: Tween = create_tween()
	tween.tween_property(bf, "modulate:a", 0.0, 0.5)
	
	await get_tree().create_timer(2.5).timeout
	
	finished.emit()
	camera.position = bf.position + Vector2(-1 * bf.camOffset.x, bf.camOffset.y)
	
	await get_tree().create_timer(0.25).timeout
	
	tween = create_tween()
	tween.tween_property(bf, "modulate:a", 1.0, 0.75)
