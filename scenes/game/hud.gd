class_name HUD extends Node2D


@export var bump_amount: Vector2 = Vector2(0.03, 0.03)

@onready var health_bar: HealthBar = %health_bar
@onready var song_label: Label = $song_label
@onready var diff_label: Label = $rating_container/diff_label
@onready var countdown_container: Node2D = $countdown_container

@onready var ratings_calculator: RatingsCalculator = %ratings_calculator
@onready var rating_container: Node2D = %rating_container
@onready var rating_sprite: Sprite2D = rating_container.get_node('rating')
var rating_tween: Tween
@onready var combo_node: Node2D = rating_container.get_node('combo')

var game: Game
var tracks: Tracks
var skin: HUDSkin


func _ready() -> void:
	if is_instance_valid(Game.instance):
		game = Game.instance
		tracks = game.tracks
	else:
		process_mode = Node.PROCESS_MODE_DISABLED
		return
	
	song_label.text = '%s • [%s]' % [game.metadata.display_name, Game.difficulty.to_upper()]
	
	skin = game.skin
	Conductor.beat_hit.connect(_on_beat_hit)
	game.ready_post.connect(_ready_post)


func _ready_post() -> void:
	game._player_field.note_hit.connect(_on_note_hit)
	game._player_field.note_miss.connect(_on_note_miss)
	Conductor.measure_hit.connect(_on_measure_hit)
	
	health_bar._ready()
	
	skin = game.skin
	combo_node.scale = skin.combo_scale
	rating_sprite.scale = skin.rating_scale
	countdown_container.scale = skin.countdown_scale


func _on_beat_hit(beat: int) -> void:
	# Countdown lol
	if Conductor.time < 0.0 and beat < 0 and not game.song_started:
		var index: int = clampi(4 - absi(beat), 0, 4)
		_display_countdown_sprite(index)
		_play_countdown_sound(index)


func _on_measure_hit(measure: int) -> void:
	if not (game.playing and game.camera_bumps):
		return
	
	scale += bump_amount


func _process(delta: float) -> void:
	if not (game.playing and game.camera_bumps):
		return
	
	scale = scale.lerp(Vector2.ONE, delta * 3.0)


func _on_note_hit(note: Note) -> void:
	var health := game.health
	var difference: float = tracks.get_playback_position() - note.data.time
	if not game._player_field.takes_input:
		difference = 0.0
	
	game.accuracy_calculator.record_hit(absf(difference))
	
	diff_label.text = '%.2fms' % [difference * 1000.0]
	diff_label.modulate = Color8(255, 176, 96) \
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
	
	rating_container.visible = true
	rating_container.modulate.a = 1.0
	rating_container.scale = Vector2(1.1, 1.1)
	rating_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	rating_tween.tween_property(rating_container, 'scale', Vector2.ONE, 0.15)
	rating_tween.tween_property(rating_container, 'modulate:a', 0.0, 0.15).set_delay(0.2)
	
	game.health = clampf(health + rating.health, 0.0, 100.0)
	game.score += rating.score
	
	var combo_str := str(game.combo).pad_zeros(3)
	combo_node.position.x = -22.5 * (combo_str.length() - 1)
	
	for i in combo_node.get_child_count():
		var number: Sprite2D = combo_node.get_child(i)
		
		if i <= combo_str.length() - 1:
			number.frame = int(combo_str[i])
			number.visible = true
		else:
			number.frame = 0
			number.visible = false
	
	health_bar.update_score_label()


func _on_note_miss(note: Note) -> void:
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
	
	var player := AudioStreamPlayerEX.new()
	player.stream = skin.countdown_sounds[index]
	player.bus = &'SFX'
	player.finished.connect(player.queue_free)
	countdown_container.add_child(player)
	player.play()
