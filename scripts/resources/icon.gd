class_name Icon extends Resource


@export var texture: Texture2D = preload('res://resources/images/game/assets/icons/face.png')
@export var color: Color = Color('a1a1a1')
@export var frames: Vector2i = Vector2i(2, 1)
@export_enum(
		'Inherit', 'Nearest', 'Linear',
		'Nearest Mipmap', 'Linear Mipmap',
		'Nearest Mipmap Anisotropic', 'Linear Mipmap Anisotropic'
) var filter: int = 0


static func create_sprite(icon: Icon) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.texture = icon.texture
	sprite.hframes = icon.frames.x
	sprite.vframes = icon.frames.y
	sprite.texture_filter = icon.filter as CanvasItem.TextureFilter
	
	return sprite
