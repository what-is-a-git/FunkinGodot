class_name SpriteElement extends Element


func _init() -> void:
	type = ElementType.SPRITE


func parse_unoptimized(input: Dictionary) -> void:
	var sprite: Dictionary = input.get('ATLAS_SPRITE_instance', {})
	name = StringName(sprite.get('name', ''))
	super(sprite.get('Matrix3D', {}))


func parse_optimized(input: Dictionary) -> void:
	var sprite: Dictionary = input.get('ASI', {})
	name = StringName(sprite.get('N', ''))
	
	# Small conversion because inheritance yucky
	var m3d: Array = sprite.get('M3D', [])
	var m3d_dict: Dictionary = {}
	for i: int in m3d.size():
		m3d_dict.set(i, m3d[i])
	super(m3d_dict)
