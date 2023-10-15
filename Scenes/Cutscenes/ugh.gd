extends Cutscene

@onready var ugh_1 = $"Ugh Cutscene Part 1"
@onready var ugh_2 = $"Ugh Cutscene Part 2"
@onready var beep = $"BF Beep"

@onready var tank_1 = $"Tankman 1"
@onready var tank_2 = $"Tankman 2"

@onready var music = $Music

@onready var hud = $"../UI"
var hud_offset: float = -720.0

var move_hud = true

var good_cam_zoom = Vector2(1,1)

@onready var mod = $"../UI/Modulate"

func _ready() -> void:
	super()
	
	mod.color.a = 0
	
	camera.position = dad.position + dad.camOffset
	
	dad.visible = false
	
	tank_1.visible = true
	tank_1.frame = 0
	tank_1.position = dad.position
	tank_1.play("cutscene")
	
	ugh_1.play()
	music.play()
	
	await get_tree().create_timer(ugh_1.stream.get_length()).timeout
	
	camera.position = bf.position + Vector2(-1 * bf.camOffset.x, bf.camOffset.y)
	
	await get_tree().create_timer(0.5).timeout
	
	beep.play()
	
	bf.timer = 0
	bf.play_animation("singUP")
	bf.dances = false
	
	await get_tree().create_timer(beep.stream.get_length() + 0.25).timeout
	
	camera.position = dad.position + dad.camOffset
	
	bf.dances = true
	tank_1.queue_free()
	
	tank_2.visible = true
	tank_2.frame = 0
	tank_2.position = dad.position
	tank_2.play("cutscene")
	
	ugh_2.play()
	
	await get_tree().create_timer(ugh_2.stream.get_length()).timeout
	
	dad.visible = true
	tank_2.queue_free()
	
	game.cam_locked = true
	
	emit_signal("finished")
	
	camera.position = dad.position + dad.camOffset
	
	move_hud = false
	
	mod.color.a = 1
	
	await get_tree().create_timer(0.5).timeout
	
	game.cam_locked = false

func _process(delta: float) -> void:
	if move_hud:
		hud.offset.y = -720.0
	else:
		hud_offset = lerp(hud_offset, 0.0, delta * 4.0)
		hud.offset.y = hud_offset
		
		if hud.offset.y > -1.0:
			queue_free()
	
	camera.zoom = good_cam_zoom
