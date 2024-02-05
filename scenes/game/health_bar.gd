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


func _ready() -> void:
	if not is_instance_valid(Game.instance):
		return
	
	player_icon = Icon.create_sprite(Game.instance.player.icon)
	player_icon.position.x = 50.0
	icons.add_child(player_icon)
	player_color = Game.instance.player.icon.color
	player_icon.flip_h = true
	
	opponent_icon = Icon.create_sprite(Game.instance.opponent.icon)
	opponent_icon.position.x = -50.0
	icons.add_child(opponent_icon)
	opponent_color = Game.instance.opponent.icon.color
	
	Conductor.on_beat_hit.connect(_on_beat_hit)


func _process(delta: float) -> void:
	if not is_instance_valid(Game.instance):
		return
	
	bar.value = Game.instance.health
	icons.position.x = 320.0 - (Game.instance.health * 6.4)
	icons.scale = lerp(icons.scale, Vector2.ONE, delta * 9.0)
	
	var player_frames: int = player_icon.hframes * player_icon.vframes
	var opponent_frames: int = opponent_icon.hframes * opponent_icon.vframes
	
	if bar.value >= 80.0:
		player_icon.frame = 2 if player_frames >= 3 else 0
		opponent_icon.frame = 1 if opponent_frames >= 2 else 0
	elif bar.value <= 20.0:
		player_icon.frame = 1 if player_frames >= 2 else 0
		opponent_icon.frame = 2 if opponent_frames >= 3 else 0


func update_score_label() -> void:
	score_label.text = 'Score:%s • Misses:%s • Accuracy:%.2f%% (%s)' % [
		Game.instance.score,
		Game.instance.misses,
		Game.instance.accuracy,
		'N/A'
	]


func _on_beat_hit(beat: int) -> void:
	icons.scale += Vector2(0.2, 0.2)
