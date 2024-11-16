extends HUD


@export var bump_amount: Vector2 = Vector2(0.03, 0.03)
@export var do_countdown: bool = true

@onready var note_fields: Node2D = %note_fields
@onready var health_bar: HealthBar = %health_bar
@onready var song_label: Label = %song_label
@onready var countdown_container: Node2D = %countdown_container

@onready var ratings_calculator: RatingsCalculator = %ratings_calculator
@onready var rating_container: Node2D = %rating_container
@onready var difference_label: Label = rating_container.get_node('difference_label')
@onready var rating_sprite: Sprite2D = rating_container.get_node('rating')
@onready var combo_node: Node2D = rating_container.get_node('combo')
var rating_tween: Tween

var allow_countdown: bool = true
var tracks: Tracks
var skin: HUDSkin


func _ready() -> void:
	super()
	
	player_field = note_fields.get_node('player')
	opponent_field = note_fields.get_node('opponent')
	
	if not is_instance_valid(game):
		return
	
	scroll_direction = Config.get_value('gameplay', 'scroll_direction')
	centered_receptors = Config.get_value('gameplay', 'centered_receptors')


func setup() -> void:
	super()
	player_field.note_hit.connect(_on_note_hit)
	player_field.note_miss.connect(_on_note_miss)
	
	skin = game.skin
	tracks = game.tracks
	combo_node.scale = skin.combo_scale
	rating_sprite.scale = skin.rating_scale
	countdown_container.scale = skin.countdown_scale
	
	song_label.text = '%s • [%s]' % [game.metadata.display_name, Game.difficulty.to_upper()]


func _ready_post() -> void:
	super()
	
	if not do_countdown:
		Conductor.time = Conductor.offset
		Conductor.beat = 0.0


func _on_beat_hit(beat: int) -> void:
	super(beat)
	
	if not do_countdown:
		return
	
	if beat >= 0 or game.song_started:
		return
	
	if not allow_countdown:
		Conductor.time = (-4.0 / Conductor.beat_delta) + Conductor.offset
		Conductor.beat = -4.0
		return
	
	# countdown lol
	var index: int = clampi(4 - absi(beat), 0, 3)
	_display_countdown_sprite(index)
	_play_countdown_sound(index)


func _on_measure_hit(measure: int) -> void:
	super(measure)
	if not (game.playing and game.camera_bumps):
		return
	
	scale += bump_amount


func _process(delta: float) -> void:
	if not (game.playing and game.camera_bumps):
		return
	
	scale = scale.lerp(Vector2.ONE, delta * 3.0)


func _on_note_hit(note: Note) -> void:
	super(note)
	var health := game.health
	var difference: float = tracks.get_playback_position() - note.data.time
	if not player_field.takes_input:
		difference = 0.0
	
	game.accuracy_calculator.record_hit(absf(difference))
	
	difference_label.text = '%.2fms' % [difference * 1000.0]
	difference_label.modulate = Color8(255, 176, 96) \
			if difference < 0.0 else Color8(111, 185, 255)
	
	if is_instance_valid(rating_tween) and rating_tween.is_running():
		rating_tween.kill()
	
	var rating := ratings_calculator.get_rating(absf(difference * 1000.0))
	match rating.name:
		&'marvelous':
			rating_sprite.texture = skin.marvelous
		&'sick':
			rating_sprite.texture = skin.sick
		&'good':
			rating_sprite.texture = skin.good
		&'bad':
			rating_sprite.texture = skin.bad
		&'shit':
			rating_sprite.texture = skin.shit
	
	if note._splash != null and \
			(rating.name == &'marvelous' or rating.name == &'sick'):
		var splash = note._splash.instantiate()
		splash.note = note
		add_child(splash)
		splash.global_position = note._field._receptors_node.\
				get_child(note.lane).global_position
	
	rating_container.visible = true
	rating_container.modulate.a = 1.0
	rating_container.scale = Vector2(1.1, 1.1)
	rating_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	rating_tween.tween_property(rating_container, 'scale', Vector2.ONE, 0.15)
	rating_tween.tween_property(rating_container, 'modulate:a', 0.0, 0.25).set_delay(0.25)
	rating_tween.tween_callback(func():
		rating_container.visible = false).set_delay(0.5)
	
	game.health = clampf(health + rating.health, 0.0, 100.0)
	game.score += rating.score
	
	var combo_str := str(game.combo).pad_zeros(3)
	combo_node.position.x = -22.5 * (combo_str.length() - 1)
	
	for i: int in combo_node.get_child_count():
		var number: Sprite2D = combo_node.get_child(i)
		
		if i <= combo_str.length() - 1:
			number.frame = int(combo_str[i])
			number.visible = true
		else:
			number.frame = 0
			number.visible = false
	
	health_bar.update_score_label()


func _on_note_miss(note: Note) -> void:
	super(note)
	rating_container.visible = false
	health_bar.update_score_label()


func _display_countdown_sprite(index: int) -> void:
	# Don't display things that don't exist.
	if not is_instance_valid(skin.countdown_textures[index]):
		return
	
	var sprite := Sprite2D.new()
	sprite.scale = Vector2(1.05, 1.05)
	sprite.texture = skin.countdown_textures[index]
	countdown_container.add_child(sprite)
	
	var tween := create_tween().set_trans(Tween.TRANS_SINE)\
			.set_ease(Tween.EASE_OUT).set_parallel()
	tween.tween_property(sprite, 'modulate:a', 0.0, 1.0 / Conductor.beat_delta)
	tween.tween_property(sprite, 'scale', Vector2.ONE, 1.0 / Conductor.beat_delta)
	tween.tween_callback(sprite.queue_free).set_delay(1.0 / Conductor.beat_delta)


func _play_countdown_sound(index: int) -> void:
	# Don't play things that don't exist.
	if not is_instance_valid(skin.countdown_sounds[index]):
		return
	
	var player := AudioStreamPlayer.new()
	player.stream = skin.countdown_sounds[index]
	player.bus = &'SFX'
	player.finished.connect(player.queue_free)
	countdown_container.add_child(player)
	player.play()


func _set_scroll_direction(value: StringName) -> void:
	var tween := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)\
			.set_parallel()
	var duration: float = 1.0 / Conductor.beat_delta if game.song_started else 0.0
	
	match value:
		&'up':
			tween.tween_property(note_fields, 'position:y', -248.0, duration)
			tween.tween_property(health_bar, 'position:y', 285.0, duration)
			tween.tween_property(song_label, 'position:y', -352.0, duration)
			song_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
			tween.tween_property(player_field, '_scroll_speed_modifier', 1.0, duration)
			tween.tween_property(opponent_field, '_scroll_speed_modifier', 1.0, duration)
		&'down':
			tween.tween_property(note_fields, 'position:y', 248.0, duration)
			tween.tween_property(health_bar, 'position:y', -285.0, duration)
			tween.tween_property(song_label, 'position:y', 288.0, duration)
			song_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
			tween.tween_property(player_field, '_scroll_speed_modifier', -1.0, duration)
			tween.tween_property(opponent_field, '_scroll_speed_modifier', -1.0, duration)
		_:
			push_warning('A scroll direction of %s is not supported.' % value)


func _set_centered_receptors(value: bool) -> void:
	var tween := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)\
			.set_parallel()
	var duration: float = 1.0 / Conductor.beat_delta if game.song_started else 0.0
	
	if value:
		if duration <= 0.0:
			player_field.position.x = 0.0
			opponent_field.position.x = 0.0
			opponent_field.modulate.a = 0.0
			tween.kill()
		else:
			tween.tween_property(player_field, 'position:x', 0.0, duration)
			tween.tween_property(opponent_field, 'position:x', 0.0, duration)
			tween.tween_property(opponent_field, 'modulate:a', 0.0, duration)
	else:
		if duration <= 0.0:
			player_field.position.x = 300.0
			opponent_field.position.x = -300.0
			opponent_field.modulate.a = 1.0
			tween.kill()
		else:
			tween.tween_property(player_field, 'position:x', 300.0, duration)
			tween.tween_property(opponent_field, 'position:x', -300.0, duration)
			tween.tween_property(opponent_field, 'modulate:a', 1.0, duration)