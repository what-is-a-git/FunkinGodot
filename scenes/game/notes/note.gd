class_name Note extends Node2D


var data: NoteData
var length: float = 0.0

const directions: PackedStringArray = ['left', 'down', 'up', 'right']

@onready var sprite: AnimatedSprite = $sprite
@onready var clip_rect: Control = $clip_rect
@onready var sustain: TextureRect = clip_rect.get_node('sustain')
@onready var tail: TextureRect = sustain.get_node('tail')

var _hit: bool = false
var _clip_target: float = NAN
var _field: NoteField = null
var _character: Character = null


func _ready() -> void:
	length = data.length
	
	sprite.animation = '%s note' % [directions[absi(data.direction) % 4]]
	sprite.play()
	
	if length > 0.0:
		var sustain_texture: AtlasTexture = sprite.sprite_frames.get_frame_texture('%s sustain' % [
			directions[absi(data.direction) % 4]
		], 0).duplicate()
		sustain_texture.region.position.y += 1
		sustain_texture.region.size.y -= 2
		
		sustain.texture = sustain_texture
		
		var tail_texture: AtlasTexture = sprite.sprite_frames.get_frame_texture('%s sustain end' % [
			directions[absi(data.direction) % 4]
		], 0).duplicate()
		tail_texture.region.position.y += 1
		tail_texture.region.size.y -= 1
		
		tail.texture = tail_texture
		
		sustain.size.y = data.length * 1000.0 * 0.45 * Game.scroll_speed / scale.y \
				- tail.texture.get_height()
		sustain.position.y = clip_rect.size.y - sustain.size.y
		sustain.z_index -= 1
	else:
		sustain.queue_free()


var _previous_sixteenth: int = -128


func _process(delta: float) -> void:
	if not _hit:
		return
	
	if length <= 0.0:
		if is_instance_valid(_character):
			_character.sing(self, true)
		
		queue_free()
		return
	
	if not is_instance_valid(_field):
		_field = get_parent().get_parent()
	
	sprite.visible = false
	length -= delta
	
	var sixteenth: int = floor(Conductor.sixteenth)
	
	if sixteenth > _previous_sixteenth:
		if is_instance_valid(_character):
			_character.sing(self, true)
		
		# Because of how this is coded this will simply play
		# the press animation over and over rather than
		# actually trying to hit the same note multiple times.
		_field.hit_note(self)
		_previous_sixteenth = sixteenth
	
	# I forgot the scale.y so many times but this works
	# as longg as the clip rect is big enough to fill the
	# whole screen (which it is rn because -1280 is more
	# than enough at 0.7 scale, which is the default)
	clip_rect.global_position.y = _clip_target - clip_rect.size.y * global_scale.y
	sustain.global_position.y = global_position.y - sustain.size.y * global_scale.y
