class_name NoteSplash extends AnimatedSprite


const colors: Array[Color] = [
	Color('c14b99'), Color('00ffff'), Color('12fa04'), Color('f9393f'),]

var note: Note


func _ready() -> void:
	modulate.a = note._field._note_splash_alpha
	if modulate.a <= 0.0:
		queue_free()
		return
	
	material = material as ShaderMaterial
	material.set_shader_parameter(&'base_color', colors[note.lane])
	play('splash %d' % [randi_range(1, sprite_frames.get_animation_names().size())])
	speed_scale = randf_range(0.9, 1.1)
