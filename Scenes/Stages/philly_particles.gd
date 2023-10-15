extends Node2D

@onready var sky = $"../../Far BG/Sky"
@onready var city = $"../../BG/City"

@onready var behind_train = $"../Behind Train"
@onready var train = $"../Train"
@onready var street = $"../Street"

@onready var part1 = $Particle1
@onready var part2 = $Particle2
@onready var part3 = $Particle3

@onready var stage = $"../../../"
@onready var game = stage.get_node("../")

@onready var blammed_shader = load("res://Assets/Shaders/Blammed Character Shader.tres")

@onready var player_icon = game.ui.get_node("Health Bar/Player")
@onready var enemy_icon = game.ui.get_node("Health Bar/Opponent")

@onready var bar = game.ui.get_node("Health Bar/Bar/ProgressBar")
@onready var bar_outline = game.ui.get_node("Health Bar/Bar/BG")

@onready var progress_bar = game.ui.get_node("Progress Bar/ProgressBar")
@onready var progress_bar_outline = game.ui.get_node("Progress Bar/BG")

@onready var world_environment: WorldEnvironment = $'../../../WorldEnvironment'

var tween: Tween

# created for blammed lol
func _ready() -> void:
	world_environment.environment.glow_enabled = false
	
	if Globals.song_name.to_lower() != "blammed":
		queue_free()
	else:
		set_particles_emitting(false)
		visible = false
		
		game.stage.connect('lights_updated', beat_hit)
		Conductor.connect("beat_hit", Callable(self, "beat_hit"))
		
		if "anim_sprite" in game.bf:
			game.bf.get_node("AnimatedSprite2D").material = blammed_shader
		if "anim_sprite" in game.gf:
			game.gf.get_node("AnimatedSprite2D").material = blammed_shader
		if "anim_sprite" in game.dad:
			game.dad.get_node("AnimatedSprite2D").material = blammed_shader
		
		player_icon.material = blammed_shader
		enemy_icon.material = blammed_shader
		bar_outline.material = blammed_shader
		progress_bar_outline.material = blammed_shader
		train.material = blammed_shader

func beat_hit() -> void:
	var cur_beat := Conductor.curBeat
	
	if cur_beat >= 192:
		var tween_time:float = (Conductor.timeBetweenBeats / Globals.song_multiplier) / 1000.0
		
		sky.modulate.a = 0
		city.modulate.a = 0
		behind_train.modulate.a = 0
		street.modulate.a = 0
		
		tween = create_tween().bind_node(get_parent()).set_parallel().set_trans(Tween.TRANS_CUBIC)
		
		tween.tween_property(sky, "modulate:a", 1.0, tween_time)
		tween.tween_property(city, "modulate:a", 1.0, tween_time)
		tween.tween_property(behind_train, "modulate:a", 1.0, tween_time)
		tween.tween_property(street, "modulate:a", 1.0, tween_time)
		
		tween.tween_property(game.gf, "modulate", Color.WHITE, tween_time)
		tween.tween_property(game.bf, "modulate", Color.WHITE, tween_time)
		tween.tween_property(game.dad, "modulate", Color.WHITE, tween_time)
		
		tween.tween_property(player_icon, "modulate", Color.WHITE, tween_time)
		tween.tween_property(enemy_icon, "modulate", Color.WHITE, tween_time)
		tween.tween_property(bar_outline, "modulate", Color.WHITE, tween_time)
		
		tween.tween_property(progress_bar_outline, "modulate", Color.WHITE, tween_time)
		
		tween.tween_property(train, "modulate", Color.WHITE, tween_time)
		
		sky.visible = true
		city.visible = true
		behind_train.visible = true
		street.visible = true
		
		blammed_shader.set("shader_parameter/enabled", false)
		
		bar.get("theme_override_styles/fill").bg_color = game.bf.health_bar_color
		bar.get("theme_override_styles/background").bg_color = game.dad.health_bar_color
		
		progress_bar.get("theme_override_styles/fill").bg_color = Color.WHITE
		
		game.default_camera_zoom = stage.camera_zoom
		set_particles_emitting(false)
		queue_free()
	elif cur_beat >= 128:
		sky.visible = false
		city.visible = false
		behind_train.visible = false
		street.visible = false
		
		visible = true
		
		blammed_shader.set("shader_parameter/enabled", true)
		
		game.gf.modulate = Color(get_light_color().r, get_light_color().g, get_light_color().b, game.gf.modulate.a)
		game.bf.modulate = get_light_color()
		game.dad.modulate = get_light_color()
		
		player_icon.modulate = get_light_color()
		enemy_icon.modulate = get_light_color()
		bar_outline.modulate = get_light_color()
		progress_bar_outline.modulate = get_light_color()
		train.modulate = get_light_color()
		
		bar.get("theme_override_styles/fill").bg_color = Color.BLACK
		bar.get("theme_override_styles/background").bg_color = Color.BLACK
	
		if game.gf.modulate.a != 0:
			tween = create_tween().set_trans(Tween.TRANS_CUBIC)
			tween.tween_property(game.gf, "modulate:a", 0.0, ((Conductor.timeBetweenSteps / Globals.song_multiplier) / 1000.0) * 2.0)
		
		game.bf.modulate.a = 1
		game.dad.modulate.a = 1
		
		if cur_beat % 2 == 0:
			game.default_camera_zoom = 1.15
			game.camera.zoom += Vector2(0.1, 0.1)
			
			game.ui_layer.scale += Vector2(0.05, 0.05)
			game.position_hud()
			
			set_particle_color(get_light_color())
			set_particles_emitting(true)
			
			await get_tree().create_timer(Conductor.timeBetweenSteps / Globals.song_multiplier, false).timeout
			set_particles_emitting(false)

func _physics_process(delta: float) -> void:
	if not blammed_shader.get("shader_parameter/enabled"):
		progress_bar.get("theme_override_styles/fill").bg_color = Color.WHITE
		return
	
	progress_bar.get("theme_override_styles/fill").bg_color = Color.BLACK
	
	var cur_beat := Conductor.curBeat
	
	if cur_beat < 192 and cur_beat >= 128:
		game.gf.modulate = Color(get_light_color().r, get_light_color().g, get_light_color().b, game.gf.modulate.a)
		game.bf.modulate = get_light_color()
		game.dad.modulate = get_light_color()
		
		player_icon.modulate = get_light_color()
		enemy_icon.modulate = get_light_color()
		bar_outline.modulate = get_light_color()
		progress_bar_outline.modulate = get_light_color()
		train.modulate = get_light_color()

func set_particles_emitting(val: bool) -> void:
	world_environment.environment.glow_enabled = val
	part1.emitting = val
	part2.emitting = val
	part3.emitting = val

func set_particle_color(color: Color) -> void:
	part1.process_material.set("color", color)
	part2.process_material.set("color", color)
	part3.process_material.set("color", color)

func get_light_color() -> Color:
	var lights: Array[Node] = stage.get_node("ParallaxBackground/BG").get_children()
	
	for light in lights:
		if not (light.name.begins_with("Light3D ") and light.visible):
			continue
		
		match(light.name.replace("Light3D ", "").to_int()):
			1:
				return Color(0.19, 0.64, 0.99, 1)
			2:
				return Color(0.19, 0.99, 0.55, 1)
			3:
				return Color(0.98, 0.2, 0.96, 1)
			4:
				return Color(0.99, 0.27, 0.19, 1)
			5:
				return Color(0.98, 0.65, 0.2, 1)
	
	return Color.WHITE
