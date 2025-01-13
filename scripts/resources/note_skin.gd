class_name NoteSkin extends Resource


@export var strum_frames: SpriteFrames = preload('res://resources/images/game/skins/default/receptors.res')
@export_enum(
		'Inherit', 'Nearest', 'Linear',
		'Nearest Mipmap', 'Linear Mipmap',
		'Nearest Mipmap Anisotropic', 'Linear Mipmap Anisotropic'
) var strum_filter: int = 0
@export var strum_scale: Vector2 = Vector2.ONE * 0.7

@export var note_frames: SpriteFrames = preload('res://resources/images/game/skins/default/notes.res')
@export_enum(
		'Inherit', 'Nearest', 'Linear',
		'Nearest Mipmap', 'Linear Mipmap',
		'Nearest Mipmap Anisotropic', 'Linear Mipmap Anisotropic'
) var note_filter: int = 0
@export var note_scale: Vector2 = Vector2.ONE * 0.7

@export var splash_frames: SpriteFrames = preload('res://resources/images/game/skins/default/splashes.res')
@export_enum(
		'Inherit', 'Nearest', 'Linear',
		'Nearest Mipmap', 'Linear Mipmap',
		'Nearest Mipmap Anisotropic', 'Linear Mipmap Anisotropic'
) var splash_filter: int = 0
@export var splash_scale: Vector2 = Vector2.ONE
