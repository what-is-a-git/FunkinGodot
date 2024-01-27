extends Cutscene

@onready var music: AudioStreamPlayer = $Music
@onready var guns: AudioStreamPlayer = $"Guns Cutscene"

@onready var tank_1: AnimatedSprite2D = $"Tankman 1"

@onready var hud: CanvasLayer = $"../UI"
var hud_offset: float = -720.0
var move_hud: bool = true

var good_cam_zoom: Vector2 = Vector2.ONE
var default_cam_zoom: float

@onready var mod: CanvasModulate = $"../UI/Modulate"

func _ready() -> void:
	super()
	default_cam_zoom = game.default_camera_zoom
	
	mod.color.a = 0
	
	camera.position = dad.position + dad.camOffset + Vector2(-175, -25)
	
	dad.visible = false
	
	tank_1.visible = true
	tank_1.frame = 0
	tank_1.position = dad.position
	tank_1.play("cutscene")
	tank_1.frame = 0
	
	await RenderingServer.frame_post_draw
	
	music.play()
	guns.play()
	
	var tween: Tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "good_cam_zoom", Vector2(1.1, 1.1), 1.5).set_delay(0.2)
	
	await get_tree().create_timer(4).timeout
	
	gf.play_animation("sad")
	gf.dances = false
	
	tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "good_cam_zoom", Vector2(1.2, 1.2), 0.5)
	
	await get_tree().create_timer(guns.stream.get_length() - 4).timeout
	
	camera.position = bf.position + Vector2(-1 * bf.camOffset.x, bf.camOffset.y)
	
	game.cam_locked = true
	
	gf.dances = true
	
	finished.emit()
	
	camera.position = dad.position + dad.camOffset
	
	move_hud = false
	
	tank_1.visible = false
	dad.visible = true
	
	mod.color.a = 1
	
	tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "good_cam_zoom", Vector2(default_cam_zoom, default_cam_zoom), 0.5)
	
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
	
	if gf.last_anim == "sad":
		if gf.anim_player:
			if gf.anim_player.current_animation == "":
				gf.play_animation("sad", true)
