extends Stage

var trainCooldown: float = 0.0
var trainFrameTiming: float = 0.0
var trainCars: float = 0.0
var time: float = 0.0

var trainMoving: bool = false
var startedMoving: bool = false
var trainFinishing: bool = false

@onready var parallax_bg = get_node("ParallaxBackground/BG")

@onready var train = $Train
@onready var train_spr: Sprite2D = $ParallaxBackground/Foreground/Train

@onready var gf: Character = $'../'.gf
@onready var gf_anim: AnimationPlayer = gf.get_node("AnimationPlayer")

var light: Sprite2D

func _ready() -> void:
	randomize()
	Conductor.connect("beat_hit", Callable(self, "on_beat"))

func _process(delta: float) -> void:
	if trainMoving:
		trainFrameTiming += delta
		
		if trainFrameTiming >= 1.0 / 24.0:
			updateTrainPos()
			trainFrameTiming = 0.0
	
	if light and light.material:
		light.material.set("shader_parameter/alpha_shit", light.material.get("shader_parameter/alpha_shit") + (1.5 * (Conductor.timeBetweenBeats / 1000.0) * delta))

func on_beat() -> void:
	if not trainMoving:
		trainCooldown = trainCooldown + 1

	if Conductor.curBeat % 4 == 0:
		var lightSelected = int(randf_range(1, 5))

		for child in parallax_bg.get_children():
			if child.name.begins_with("Light3D "):
				child.visible = false
		
		light = parallax_bg.get_node("Light3D " + str(lightSelected))
		light.visible = true
		
		if light.material:
			light.material.set("shader_parameter/alpha_shit", 0)

	if Conductor.curBeat % 8 == 4 and randf_range(0, 100) < 20 and not trainMoving and trainCooldown > 8:
		trainCooldown = int(randf_range(-4, 0))
		
		trainMoving = true
		train.play(0)

func updateTrainPos():
	if train.get_playback_position() * 1000 >= 4700:
		gf.dances = false
		
		if not startedMoving:
			gf.play_animation("hairBlow", true)
		
		startedMoving = true
		
		if gf_anim.get_current_animation_position() >= 0.16:
			gf.play_animation("hairBlow", true)

	if startedMoving:
		train_spr.position.x = train_spr.position.x - 400
		
		if train_spr.position.x < -2000 and not trainFinishing:
			train_spr.position.x = -1150
			trainCars = trainCars - 1
			
			if trainCars <= 0:
				trainFinishing = true
		
		if train_spr.position.x < -4000 and trainFinishing:
			trainReset()

func trainReset():
	gf.play_animation("hairFall", true)
	
	train_spr.position.x = 2000
	trainMoving = false
	trainCars = 8
	trainFinishing = false
	startedMoving = false
	
	gf.dances = true
