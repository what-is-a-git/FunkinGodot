class_name Receptor extends AnimatedSprite


@export var direction: StringName = &'left'
var _automatically_play_static: bool = false:
	set(value):
		if _automatically_play_static != value:
			if value:
				animation_finished.connect(_on_animation_finished)
			elif animation_finished.is_connected(_on_animation_finished):
				animation_finished.disconnect(_on_animation_finished)
			
			_automatically_play_static = value


func _ready() -> void:
	if _automatically_play_static:
		animation_finished.connect(_on_animation_finished)


func play_anim(anim: StringName, force: bool = false) -> void:
	play('%s %s' % [direction, anim])
	
	if force:
		frame = 0


func _on_animation_finished() -> void:
	if animation.ends_with('static'):
		return
	
	play_anim('static')
