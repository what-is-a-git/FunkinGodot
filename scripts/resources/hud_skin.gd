class_name HUDSkin extends Resource


@export_category('Ratings')

@export var marvelous: Texture2D = preload('res://resources/images/game/skins/default/ratings/marvelous.png')
@export var sick: Texture2D = preload('res://resources/images/game/skins/default/ratings/sick.png')
@export var good: Texture2D = preload('res://resources/images/game/skins/default/ratings/good.png')
@export var bad: Texture2D = preload('res://resources/images/game/skins/default/ratings/bad.png')
@export var shit: Texture2D = preload('res://resources/images/game/skins/default/ratings/shit.png')
@export var rating_scale: Vector2 = Vector2(0.7, 0.7)
@export_enum(
		'Inherit', 'Nearest', 'Linear',
		'Nearest Mipmap', 'Linear Mipmap',
		'Nearest Mipmap Anisotropic', 'Linear Mipmap Anisotropic'
) var rating_filter: int = 0

@export_category('Combo')

## It is expected there are images 0-9.png in this folder as they will be
## all preloaded by default.
@export var combo_atlas: Texture2D = preload('res://resources/images/game/skins/default/combo/numbers.png')
@export var combo_scale: Vector2 = Vector2(0.5, 0.5)
@export_enum(
		'Inherit', 'Nearest', 'Linear',
		'Nearest Mipmap', 'Linear Mipmap',
		'Nearest Mipmap Anisotropic', 'Linear Mipmap Anisotropic'
) var combo_filter: int = 0

@export_category('Countdown')

@export var countdown_textures: Array[Texture2D] = [
	null,
	preload('res://resources/images/game/skins/default/countdown/ready.png'),
	preload('res://resources/images/game/skins/default/countdown/set.png'),
	preload('res://resources/images/game/skins/default/countdown/go.png'),
]
@export var countdown_sounds: Array[AudioStream] = [
	preload('res://resources/sfx/game/countdown/3.ogg'),
	preload('res://resources/sfx/game/countdown/2.ogg'),
	preload('res://resources/sfx/game/countdown/1.ogg'),
	preload('res://resources/sfx/game/countdown/go.ogg'),
]
@export var countdown_scale: Vector2 = Vector2(0.7, 0.7)
@export_enum(
		'Inherit', 'Nearest', 'Linear',
		'Nearest Mipmap', 'Linear Mipmap',
		'Nearest Mipmap Anisotropic', 'Linear Mipmap Anisotropic'
) var countdown_filter: int = 0

@export_category('Misc')

@export var pause_menu: PackedScene = null
@export var pause_music: AudioStream = null
