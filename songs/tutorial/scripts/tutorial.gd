extends FunkinScript


func _ready() -> void:
	super()
	
	if not (is_instance_valid(game) and is_instance_valid(camera)):
		print(game)
		print(camera)
		return
	
	create_tween().set_trans(Tween.TRANS_ELASTIC).tween_property(
		camera, 'zoom', Vector2(1.3, 1.3), 1.0 / Conductor.beat_delta
	)
	
	if not (is_instance_valid(opponent) and is_instance_valid(spectator)):
		return
	
	if opponent.name == &'null':
		game.opponent = spectator
		game.spectator = opponent
		opponent = spectator
		spectator = game.spectator
		
		game.target_camera_position = opponent._camera_offset.global_position
		camera.position = game.target_camera_position
		
		game.hud.health_bar._ready()
		opponent_field._default_character = opponent


func _process(delta: float) -> void:
	game.camera_bumps = false


func _on_beat_hit(beat: int) -> void:
	if not (is_instance_valid(spectator) and is_instance_valid(player)):
		queue_free()
		return
	
	


func _on_event_hit(event: EventData) -> void:
	if event.name.to_lower() != &'camera pan':
		return
	if event.data[0] == CameraPan.Side.PLAYER:
		create_tween().set_trans(Tween.TRANS_ELASTIC).tween_property(
			camera, 'zoom', Vector2.ONE, 1.0 / Conductor.beat_delta
		)
	else:
		create_tween().set_trans(Tween.TRANS_ELASTIC).tween_property(
			camera, 'zoom', Vector2(1.3, 1.3), 1.0 / Conductor.beat_delta
		)
