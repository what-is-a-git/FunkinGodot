class_name CollectedSprite extends Resource


@export var rect: Rect2i
@export var rotated: bool
@export var custom_texture: Texture2D


func free() -> void:
	custom_texture = null


func _to_string() -> String:
	return '{ "rect": %s, "rotated": %s }' % [rect, rotated]
