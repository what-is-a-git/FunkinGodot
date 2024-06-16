class_name HealthBar extends Node2D


@onready var bar: ProgressBar = $bar
@onready var icons: Node2D = $icons
@onready var score_label: Label = $score_label

var player_icon: Sprite2D = null
var player_color: Color:
	set(value):
		player_color = value
		bar.get('theme_override_styles/fill').bg_color = player_color

var opponent_icon: Sprite2D = null
var opponent_color: Color:
	set(value):
		opponent_color = value
		bar.get('theme_override_styles/background').bg_color = opponent_color
var rank: StringName = &'N/A'


func _ready() -> void:
	if not is_instance_valid(Game.instance):
		return
	
	if is_instance_valid(player_icon) and is_instance_valid(opponent_icon):
		player_icon.queue_free()
		opponent_icon.queue_free()
	
	player_icon = Icon.create_sprite(Game.instance.player.icon)
	player_icon.position.x = 50.0
	icons.add_child(player_icon)
	player_color = Game.instance.player.icon.color
	player_icon.flip_h = true
	
	opponent_icon = Icon.create_sprite(Game.instance.opponent.icon)
	opponent_icon.position.x = -50.0
	icons.add_child(opponent_icon)
	opponent_color = Game.instance.opponent.icon.color


func _icon_ease(x: float) -> float:
	return sin(x * PI / 2.0)


func _icon_lerp() -> float:
	return _icon_ease(Conductor.beat - floorf(Conductor.beat))


func _process(delta: float) -> void:
	if not is_instance_valid(Game.instance):
		return
	
	bar.value = Game.instance.health
	icons.scale = Vector2(1.2, 1.2).lerp(Vector2.ONE, _icon_lerp())
	call_deferred('_position_icons')
	
	var player_frames: int = player_icon.hframes * player_icon.vframes
	var opponent_frames: int = opponent_icon.hframes * opponent_icon.vframes
	
	if bar.value >= 80.0:
		player_icon.frame = 2 if player_frames >= 3 else 0
		opponent_icon.frame = 1 if opponent_frames >= 2 else 0
	elif bar.value <= 20.0:
		player_icon.frame = 1 if player_frames >= 2 else 0
		opponent_icon.frame = 2 if opponent_frames >= 3 else 0
	else:
		player_icon.frame = 0
		opponent_icon.frame = 0


func update_score_label() -> void:
	const ranks: Array = [
		[0.0, &'F'],
		[50.0, &'F+'],
		[60.0, &'D'],
		[70.0, &'C'],
		[80.0, &'B'],
		[90.0, &'A'],
		[95.0, &'S'],
		[100.0, &'S+'],
	]
	rank = &'N/A'
	
	for rank_data: Array in ranks:
		if Game.instance.accuracy >= rank_data[0]:
			rank = rank_data[1]
			continue
		break
	
	score_label.text = 'Score:%s • Misses:%s • Accuracy:%.3f%% (%s)' % [
		Game.instance.score,
		Game.instance.misses,
		Game.instance.accuracy,
		rank,
	]


func _position_icons() -> void:
	icons.position.x = 320.0 - (Game.instance.health * 6.4)
