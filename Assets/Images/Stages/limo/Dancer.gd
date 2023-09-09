extends AnimatedSprite

var left := false
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	_dance()
	Conductor.beat_hit.connect(_dance)

func _dance() -> void:
	animation_player.play('danceLeft' if left else 'danceRight')
	left = not left
