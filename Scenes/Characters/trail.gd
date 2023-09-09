extends Node2D

@onready var sprite: AnimatedSprite2D = $"../AnimatedSprite2D"

@export var length: int = 10
@export var delay: int = 3
@export var alpha: float = 0.4
@export var diff: float = 0.05

var frame: float = 0.0

var _recent_positions: Array = []
var _recent_frames: Array = []

var sprite_position: Vector2 = Vector2()

func _ready() -> void:
	increase_length(length)

func _process(delta: float) -> void:
	frame += delta
	
	if frame >= (1.0 / 60.0) * delay && length >= 1:
		frame = 0
		
		if _recent_positions.size() == length - 1:
			_recent_positions.pop_back()
		if _recent_frames.size() == length - 1:
			_recent_frames.pop_back()
		
		sprite_position = Vector2(sprite.position.x, sprite.position.y)
		_recent_positions.push_front(sprite_position)
		_recent_frames.push_front([sprite.offset, sprite.animation, sprite.frame])
		
		for i in _recent_positions.size():
			var trail_sprite: AnimatedSprite2D = get_child(i)
			trail_sprite.position.x = _recent_positions[i].x
			trail_sprite.position.y = _recent_positions[i].y
			
			trail_sprite.offset = _recent_frames[i][0]
			trail_sprite.animation = _recent_frames[i][1]
			trail_sprite.frame = _recent_frames[i][2]
			
			trail_sprite.visible = true

func increase_length(amount:int) -> void:
	if amount < 1:
		return
	
	for i in amount:
		var trail_sprite: AnimatedSprite2D = sprite.duplicate()
		trail_sprite.playing = false
		add_child(trail_sprite)
		
		trail_sprite.modulate.a = alpha
		alpha -= diff

		if trail_sprite.modulate.a <= 0:
			trail_sprite.visible = false
