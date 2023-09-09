extends Panel

@onready var path = $Path3D
@onready var button = $Button

@onready var sprite_data = $SpriteData

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func convert_xml():
	if path.text != "":
		var path_string:String
		
		if path.text.ends_with(".png") or path.text.ends_with(".txt"):
			path_string = "res://" + path.text.left(len(path.text) - 4)
		else:
			path_string = "res://" + path.text
		
		if path_string.begins_with("res://res://"):
			path_string = path_string.right(6)
		
		var texture = load(path_string + ".png")
		
		if texture != null:
			var frames = SpriteFrames.new()
			
			var txt = File.new()
			txt.open(path_string + ".txt", File.READ)
			
			sprite_data.frames = frames
			
			var lines = txt.get_as_text().split("\n")
			
			for line in lines:
				if line != "":
					var data = line.split("=")
					
					var animation_name = data[0].split("_")[0]
					
					var sprite_data = data[1].right(1).split(" ")
					
					var frame_rect = Rect2(
						Vector2(
							int(sprite_data[0]),
							int(sprite_data[1])
						),
						Vector2(
							int(sprite_data[2]),
							int(sprite_data[3])
						)
					)
					
					var frame_data = AtlasTexture.new()
					frame_data.atlas = texture
					frame_data.region = frame_rect
					frame_data.flags = Texture2D.FLAG_MIPMAPS
					frame_data.filter_clip = true
					
					if !frames.has_animation(animation_name):
						frames.add_animation_library(animation_name)
						frames.set_animation_loop(animation_name, false)
						frames.set_animation_speed(animation_name, 24)
					
					frames.add_frame(animation_name, frame_data)
			
			frames.remove_animation_library("default")
			ResourceSaver.save(path_string + ".res", frames, ResourceSaver.FLAG_COMPRESS)
			
			for anim in frames.animations:
				sprite_data.play(anim.name)
				await get_tree().create_timer(0.01).timeout
		else:
			print(path_string + " loading failed.")

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		
		Scenes.switch_scene("Tools Menu")
