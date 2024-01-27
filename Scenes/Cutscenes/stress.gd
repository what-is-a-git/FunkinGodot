extends Cutscene

@onready var cutscene: AudioStreamPlayer = $Cutscene

@onready var hud: CanvasLayer = $"../UI"
var hud_offset: float = -720.0
var move_hud: bool = true

@onready var tank_1: AnimatedSprite2D = $"Tankman 1"
@onready var tank_2: AnimatedSprite2D = $"Tankman 2"

var parts: Array = []

var good_cam_zoom: Vector2 = Vector2(1,1)

@onready var dumb_bf: Character = load("res://Scenes/Characters/bf.tscn").instantiate()

@onready var mod: CanvasModulate = $"../UI/Modulate"

func _ready():
	bf.visible = false
	
	game.add_child(dumb_bf)
	dumb_bf.position = bf.position
	dumb_bf.visible = true
	dumb_bf.scale.x *= -1
	
	mod.color.a = 0
	
	for i in 6:
		parts.push_back(get_node("Part " + str(i + 1)))
		parts[i].position = gf.position
	
	camera.position = dad.position + dad.camOffset + Vector2(50.0, 0.0)
	
	var tween: Tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(camera, "position:x", camera.position.x - 50, 1.0)
	
	dad.visible = false
	gf.visible = false
	dumb_bf.z_index += 1
	bf.z_index += 1
	
	parts[0].visible = true
	
	tank_1.position = dad.position
	tank_1.visible = true
	tank_1.play("cutscene")
	tank_1.frame = 0
	
	await RenderingServer.frame_post_draw
	
	cutscene.play()
	
	await get_tree().create_timer(15.5).timeout
	
	camera.position.x += 150
	camera.position.y -= 150
	
	tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "good_cam_zoom", Vector2(0.8, 0.8), 0.5)
	
	play_part(1)
	
	await get_tree().create_timer(1.4).timeout
	
	tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "good_cam_zoom", Vector2(1.2, 1.2), 1.0)
	
	play_part(2)
	
	parts[0].frames = null
	parts[0].visible = false
	
	await get_tree().create_timer(1).timeout
	
	parts[1].frames = null
	parts[1].visible = false
	
	play_part(3)
	play_part(4, false)
	play_part(5, false)
	
	bf.visible = true
	bf.play_animation("bfCatch", true)
	dumb_bf.queue_free()
	
	await get_tree().create_timer(1.8).timeout
	
	camera.position = dad.position + dad.camOffset + Vector2(50, 0)
	
	tank_1.visible = false
	tank_1.queue_free()
	
	tank_2.position = dad.position
	tank_2.visible = true
	tank_2.frame = 0
	tank_2.play("cutscene")
	
	await get_tree().create_timer(2).timeout
	
	parts[2].frames = null
	parts[2].visible = false
	
	parts[3].frames = null
	parts[3].visible = false
	
	parts[4].frames = null
	parts[4].visible = false
	
	play_part(6)
	
	await get_tree().create_timer(10).timeout
	
	camera.position = bf.position + Vector2(-1 * bf.camOffset.x, bf.camOffset.y) + Vector2(50, 0)
	
	bf.timer = 0
	bf.play_animation("singUPmiss")
	bf.dances = false
	
	good_cam_zoom = Vector2(1.3, 1.3)
	
	await get_tree().create_timer(0.75).timeout
	
	camera.position = dad.position + dad.camOffset
	
	good_cam_zoom = Vector2.ONE
	
	bf.dances = true
	
	await get_tree().create_timer(3.25).timeout
	
	play_part(1)
	
	dad.visible = true
	gf.visible = true
	tank_2.queue_free()
	
	game.cam_locked = true
	
	finished.emit()
	
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

func play_part(part_index: int, hide_previous: bool = true):
	for i in len(parts):
		var part = parts[i]
		
		if i == part_index - 1:
			part.visible = true
			part.frame = 0
			part.play("cutscene")
		elif hide_previous:
			part.visible = false
