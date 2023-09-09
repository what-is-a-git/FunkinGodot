extends AnimatedSprite2D

var strum_time: float = 0.0
var going_right: bool = false
var speed: float = 0.7

var end_offset: float = 50

func _ready() -> void:
	randomize()
	play("run")

func _process(_delta: float) -> void:
	if animation == "run":
		var wacky_shit: float = (1280 * 0.74) + end_offset
		
		if going_right:
			wacky_shit = (1280 * 0.02) - end_offset
			position.x = wacky_shit + (Conductor.songPosition - strum_time) * speed
		else:
			position.x = wacky_shit - (Conductor.songPosition - strum_time) * speed
		
		if Conductor.songPosition >= strum_time:
			play("shot" + str(round(randf_range(1, 2))))
			frame = 0
			
			if going_right:
				offset = Vector2(-300, -200)
	
	if animation.begins_with("shot") and frame >= sprite_frames.get_frame_count(animation) - 1:
		queue_free()

func set_values(x: float, y: float, _going_right: bool):
	position = Vector2(x, y)
	going_right = _going_right
	
	end_offset = randf_range(50, 200)
	speed = randf_range(0.6, 1)
	
	if going_right:
		flip_h = true
