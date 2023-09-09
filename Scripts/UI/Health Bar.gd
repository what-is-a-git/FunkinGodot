extends Node2D

@onready var iconP1 = $Player
@onready var iconP2 = $Opponent

@onready var barBG = $Bar/Sprite2D
@onready var bar = $Bar/ProgressBar

@onready var game = $"../../"

@onready var bounce_type: String = Settings.get_data('health_icon_bounce')

var icon_bounce: IconBounce

func _ready():
	if ResourceLoader.exists('res://Scripts/UI/Icons/%s.gd' % bounce_type):
		icon_bounce = load('res://Scripts/UI/Icons/%s.gd' % bounce_type).new()
	else:
		icon_bounce = load('res://Scripts/UI/Icons/default.gd').new()
	
	add_child(icon_bounce)
	
	icon_bounce.iconP1 = iconP1
	icon_bounce.iconP2 = iconP2
	
	Conductor.connect('step_hit' if icon_bounce.runs_on_step else 'beat_hit', icon_bounce.beat_hit)

func _process(delta: float) -> void:
	bar.value = game.health
	game.health = bar.value
	
	icon_bounce.health = game.health
	icon_bounce.on_process(delta)
	
	var redone_percent: float = remap(game.health, 0.0, 2.0, 100.0, 0) / 100.0
	
	iconP1.global_position.x = bar.position.x + ((592 * redone_percent) - 150) - (150 / 3)
	iconP2.global_position.x = bar.position.x + ((592 * redone_percent) - 150) - (150 * 1.1)
	
	iconP1.frame = 0
	iconP2.frame = 0
	
	if redone_percent <= 0.2:
		if iconP1.hframes >= 3:
			iconP1.frame = 2
		
		if iconP2.hframes >= 2:
			iconP2.frame = 1
	elif redone_percent >= 0.8:
		if iconP1.hframes >= 2:
			iconP1.frame = 1
		
		if iconP2.hframes >= 3:
			iconP2.frame = 2
	
	if redone_percent >= 1.0:
		if game.bf:
			Globals.death_character_name = game.bf.death_character
			Globals.death_character_pos = game.bf.global_position
		
		Globals.death_character_cam = game.camera.position
		Scenes.switch_scene('Gameover', true)
