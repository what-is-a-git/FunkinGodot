extends Panel

# VARIABLES #
@onready var sprite_data = $"../SpriteData"

var path: String = "res://Assets/Images/Characters/bf/assets"
var fps: int = 24
var looped: bool = false
var optimized: bool = true

func convert_xml():
	if path != "":
		var path_string:String
		
		if path.ends_with(".png") or path.ends_with(".xml"):
			path_string = "res://" + path.left(len(path) - 4)
		else:
			path_string = "res://" + path
		
		if path_string.begins_with("res://res://"):
			path_string = path_string.right(6)
		
		var texture = load(path_string + ".png")
		
		if texture != null:
			var frames = SpriteFrames.new()
			frames.remove_animation_library("default")
			
			var xml = XMLParser.new()
			xml.open(path_string + ".xml")
			
			sprite_data.frames = frames
			
			var previous_texture: AtlasTexture
			var previous_coords: Rect2
			
			while xml.read() == OK:
				if xml.get_node_type() != XMLParser.NODE_TEXT:
					var node_name = xml.get_node_name()
					
					if node_name.to_lower() == "subtexture":
						var frame_data: AtlasTexture
						
						var animation_name = xml.get_named_attribute_value("name")
						animation_name = animation_name.left(len(animation_name) - 4)
						
						var frame_rect = Rect2(
							Vector2(
								xml.get_named_attribute_value("x").to_int(),
								xml.get_named_attribute_value("y").to_int()
							),
							Vector2(
								xml.get_named_attribute_value("width").to_int(),
								xml.get_named_attribute_value("height").to_int()
							)
						)
						
						if optimized and previous_coords == frame_rect:
							frame_data = previous_texture
						else:
							var margin: Rect2
							
							if xml.has_attribute("frameX"):
								var frame_size_data = Vector2(
									xml.get_named_attribute_value("frameWidth").to_int(),
									xml.get_named_attribute_value("frameHeight").to_int()
								)
								
								if frame_size_data == Vector2(0,0):
									frame_size_data = frame_rect.size
								
								margin = Rect2(
									Vector2(
										-int(xml.get_named_attribute_value("frameX")),
										-int(xml.get_named_attribute_value("frameY"))
									),
									Vector2(
										int(xml.get_named_attribute_value("frameWidth")) - frame_rect.size.x,
										int(xml.get_named_attribute_value("frameHeight")) - frame_rect.size.y
									)
								)
								
								if margin.size.x < abs(margin.position.x):
									margin.size.x = abs(margin.position.x)
								if margin.size.y < abs(margin.position.y):
									margin.size.y = abs(margin.position.y)

							frame_data = AtlasTexture.new()
							frame_data.atlas = texture
							frame_data.region = frame_rect
							
							if xml.has_attribute("frameX"):
								frame_data.margin = margin
							
							frame_data.filter_clip = true
						
						if optimized:
							previous_texture = frame_data
							previous_coords = frame_rect
						
						if !frames.has_animation(animation_name):
							frames.add_animation_library(animation_name)
							frames.set_animation_loop(animation_name, looped)
							frames.set_animation_speed(animation_name, fps)
						
						frames.add_frame(animation_name, frame_data)
			
			ResourceSaver.save(frames, path_string + ".res", ResourceSaver.FLAG_COMPRESS)
			
			for anim in frames.animations:
				sprite_data.play(anim.name)
				await get_tree().create_timer((1.0 / frames.get_animation_speed(anim.name)) * frames.get_frame_count(anim.name)).timeout
		else:
			print(path_string + " loading failed.")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

# funny signal shits
func set_path(new_path: String):
	path = new_path
	print(new_path)

func set_fps(new_fps: String):
	fps = int(new_fps)

func set_looped(new_looped: bool):
	looped = new_looped

func set_optimized(new_optimized: bool):
	optimized = new_optimized

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		
		Scenes.switch_scene("Tools Menu")
