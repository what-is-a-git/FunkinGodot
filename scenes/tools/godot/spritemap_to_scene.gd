extends Node2D


@export var spritemap: String = 'res://songs/extra/weekend1/assets/characters/abot/abotSystem'

var main_symbol: SymbolData
var symbol_dict: Dictionary = {}
var spritemap_dict: Dictionary = {}
var texture: Texture2D

var frame_timer: float = 0.0
var framerate: float = 24.0
var current_frame: int = 0
var length: int = 0
var optimized: bool = false


func _ready() -> void:
	_do_shit()


func _process(delta: float) -> void:
	var last_frame := current_frame
	frame_timer += delta
	current_frame = wrapi(int(frame_timer * framerate), 0, length)
	
	if current_frame != last_frame:
		queue_redraw()


func _do_shit() -> void:
	var start: int = Time.get_ticks_usec()
	
	if not spritemap.ends_with('/'):
		spritemap = spritemap + '/'
	
	texture = load(spritemap + 'spritemap1.png')
	var spritemap_data: Dictionary = \
			JSON.parse_string(FileAccess.get_file_as_string(spritemap + 'spritemap1.json'))
	spritemap_data = spritemap_data.ATLAS
	
	for sprite in spritemap_data.SPRITES:
		# add_child(_create_debug_sprite(sprite.SPRITE, texture))
		spritemap_dict[sprite.SPRITE.name] = _get_atlas_sprite_from_data(sprite.SPRITE)
	
	# print(spritemap_dict)
	
	var animation_data: Dictionary = \
			JSON.parse_string(FileAccess.get_file_as_string(spritemap + 'Animation.json'))
	optimized = animation_data.has('MD')
	
	if optimized:
		framerate = float(animation_data.MD.FRT)
	else:
		framerate = float(animation_data.metadata.framerate)
	
	# build the symbol dictionary
	if optimized:
		for symbol in animation_data.SD.S:
			symbol_dict[symbol.SN] = _get_symbol_data(symbol)
	else:
		for symbol in animation_data.SYMBOL_DICTIONARY.Symbols:
			symbol_dict[symbol.SYMBOL_name] = _get_symbol_data(symbol)
	
	# print(symbol_dict)
	
	if optimized:
		main_symbol = _get_symbol_data(animation_data.AN)
	else:
		main_symbol = _get_symbol_data(animation_data.ANIMATION)
	length = main_symbol.length
	
	print('took %f ms to process shiz' % [float(Time.get_ticks_usec() - start) / 1000.0])
	# print(main_symbol)
	queue_redraw()


func _draw() -> void:
	var offset := SymbolOffset.new()
	offset.transform = Transform2D.IDENTITY
	_draw_symbol(main_symbol, current_frame, offset)


func _draw_symbol(symbol: SymbolData, drawn_frame: int, offset: SymbolOffset) -> void:
	for layer in symbol.layers:
		for frame in layer.frames:
			if drawn_frame < frame.index:
				continue
			if drawn_frame > frame.index + (frame.duration - 1):
				continue
			
			for element in frame.elements:
				if element is SymbolElement:
					var new_offset := SymbolOffset.new()
					new_offset.transform = offset.transform * element.transform
					
					var data := symbol_dict[element.name] as SymbolData
					var frm: int = 0
					
					match element.loop_mode:
						SymbolLoopMode.PLAY_ONCE:
							frm = clampi(element.frame + current_frame - frame.index, 0, data.length - 1)
						_:
							frm = wrapi(element.frame + current_frame - frame.index, 0, data.length - 1)
					
					_draw_symbol(data, frm, new_offset)
				if element is AtlasSpriteElement:
					_draw_atlas_sprite(element as AtlasSpriteElement, offset)
			
			break


func _draw_atlas_sprite(atlas_sprite: AtlasSpriteElement, offset: SymbolOffset) -> void:
	var data: AtlasSprite = spritemap_dict[atlas_sprite.name]
	
	draw_set_transform_matrix(offset.transform)
	draw_texture_rect_region(texture, Rect2(Vector2.ZERO, Vector2(data.size)), 
			Rect2(Rect2i(data.position, data.size)))


func _get_symbol_data(data: Dictionary) -> SymbolData:
	var return_data := SymbolData.new()
	return_data.name = data.SN if optimized else data.SYMBOL_name
	return_data.layers = []
	return_data.length = 0
	
	var layers = data.TL.L if optimized else data.TIMELINE.LAYERS
	for layer in layers:
		var new_layer := _get_layer_from_data(layer)
		if new_layer.length > return_data.length:
			return_data.length = new_layer.length
		
		return_data.layers.push_back(new_layer)
	
	return_data.layers.reverse()
	return return_data


func _get_layer_from_data(layer_data: Dictionary) -> SymbolLayer:
	var layer := SymbolLayer.new()
	layer.name = layer_data.LN if optimized else layer_data.Layer_name
	layer.frames = []
	layer.length = 0
	
	var frames = layer_data.FR if optimized else layer_data.Frames
	for frame in frames:
		var new_frame := _get_frame_from_data(frame)
		if new_frame.index + new_frame.duration > layer.length:
			layer.length = new_frame.index + new_frame.duration
		
		layer.frames.push_back(new_frame)
	
	return layer


func _get_frame_from_data(frame_data: Dictionary) -> SymbolFrame:
	var frame := SymbolFrame.new()
	frame.index = frame_data.I if optimized else frame_data.index
	frame.duration = frame_data.DU if optimized else frame_data.duration
	frame.elements = []
	
	var elements = frame_data.E if optimized else frame_data.elements
	for element in elements:
		frame.elements.push_back(_get_element_from_data(element))
	
	return frame


func _get_element_from_data(element_data: Dictionary) -> FrameElement:
	var element: FrameElement = null
	
	if optimized:
		if element_data.has('SI'):
			element = _get_element_from_symbol(element_data.SI)
		if element_data.has('ASI'):
			element = _get_element_from_atlas_sprite(element_data.ASI)
	else:
		if element_data.has('SYMBOL_Instance'):
			element = _get_element_from_symbol(element_data.SYMBOL_Instance)
		if element_data.has('ATLAS_SPRITE_instance'):
			element = _get_element_from_atlas_sprite(element_data.ATLAS_SPRITE_instance)
	
	return element


func _get_element_from_symbol(element_data: Dictionary) -> SymbolElement:
	var element := SymbolElement.new()
	element.name = element_data.SN if optimized else element_data.SYMBOL_name
	element.frame = element_data.get('firstFrame', 0)
	
	if optimized:
		if element_data.has('LP'):
			element.loop_mode = SymbolLoopMode.LOOP if element_data.LP == 'LP' else \
				SymbolLoopMode.PLAY_ONCE
		else:
			element.loop_mode = SymbolLoopMode.PLAY_ONCE
	else:
		if element_data.has('loop'):
			element.loop_mode = SymbolLoopMode.LOOP if element_data.loop == 'loop' else \
				SymbolLoopMode.PLAY_ONCE
		else:
			element.loop_mode = SymbolLoopMode.PLAY_ONCE
	
	if optimized:
		var mat: Array = element_data.M3D
		element.transform = Transform2D(Vector2(mat[0], mat[1]),
				Vector2(mat[4], mat[5]),
				Vector2(mat[12], mat[13]))
	else:
		var mat: Dictionary = element_data.Matrix3D
		element.transform = Transform2D(Vector2(mat.m00, mat.m01),
				Vector2(mat.m10, mat.m11),
				Vector2(mat.m30, mat.m31))
	
	return element


func _get_element_from_atlas_sprite(element_data: Dictionary) -> AtlasSpriteElement:
	var element := AtlasSpriteElement.new()
	element.name = element_data.N if optimized else element_data.name
	
	if optimized:
		var mat: Array = element_data.M3D
		element.transform = Transform2D(Vector2(mat[0], mat[1]),
				Vector2(mat[4], mat[5]),
				Vector2(mat[12], mat[13]))
	else:
		var mat: Dictionary = element_data.Matrix3D
		element.transform = Transform2D(Vector2(mat.m00, mat.m01),
				Vector2(mat.m10, mat.m11),
				Vector2(mat.m30, mat.m31))
	
	return element


func _get_atlas_sprite_from_data(sprite_data: Dictionary) -> AtlasSprite:
	var atlas_sprite := AtlasSprite.new()
	atlas_sprite.name = sprite_data.name
	atlas_sprite.position = Vector2i(sprite_data.x, sprite_data.y)
	atlas_sprite.size = Vector2i(sprite_data.w, sprite_data.h)
	atlas_sprite.rotated = sprite_data.get('rotated', false)
	return atlas_sprite


func _create_debug_sprite(sprite_data: Dictionary, texture: Texture2D) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.name = sprite_data.name
	sprite.texture = texture
	sprite.centered = false
	sprite.position.x = sprite_data.x
	sprite.position.y = sprite_data.y
	sprite.region_enabled = true
	sprite.region_rect = Rect2(sprite.position.x, sprite.position.y,
			sprite_data.w, sprite_data.h)
	
	return sprite

# drawing

class SymbolOffset extends RefCounted:
	var transform: Transform2D

# symbol dict stuff

class SymbolData extends RefCounted:
	var name: StringName
	var layers: Array[SymbolLayer]
	var length: int
	
	func _to_string() -> String:
		return 'SymbolData("%s", %s)' % [name, layers]


class SymbolLayer extends RefCounted:
	var name: StringName
	var frames: Array[SymbolFrame]
	var length: int
	
	func _to_string() -> String:
		return 'SymbolLayer("%s", %s)' % [name, frames]


class SymbolFrame extends RefCounted:
	var index: int
	var duration: int
	var elements: Array[FrameElement]
	
	func _to_string() -> String:
		return 'SymbolFrame(%s, %s, %s)' % [index, duration, elements]


class FrameElement extends RefCounted:
	var name: StringName
	var transform: Transform2D
	
	func _to_string() -> String:
		return 'FrameElement("%s", %s)' % [name, transform]


class AtlasSpriteElement extends FrameElement:
	pass


class SymbolElement extends FrameElement:
	var frame: int
	var loop_mode: SymbolLoopMode
	
	func _to_string() -> String:
		return 'SymbolElement("%s", %s, %s, %s, %s, %s)' % [name, transform, frame, loop_mode]


enum SymbolLoopMode {
	PLAY_ONCE,
	LOOP
}

# spritemap stuff

class AtlasSprite extends RefCounted:
	var name: StringName
	var position: Vector2i
	var size: Vector2i
	var rotated: bool
	
	func _to_string() -> String:
		return 'AtlasSprite("%s", %s, %s, %s)' % [name, position, size, rotated]
