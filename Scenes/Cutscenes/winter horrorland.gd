extends Cutscene

@onready var black_screen: ColorRect = $ColorRect
@onready var lights: AudioStreamPlayer = $Lights
@onready var evil_point: Node2D = $"Evil Point"

@onready var hud_mod: CanvasModulate = game.get_node("UI/Modulate")

var good_cam_zoom: Vector2 = Vector2(0.5, 0.5)

func _ready() -> void:
	camera.position = evil_point.position
	hud_mod.color.a = 0
	
	await get_tree().create_timer(1).timeout
	
	black_screen.queue_free()
	lights.play()
	
	await get_tree().create_timer(0.8).timeout
	
	hud_mod.color.a = 1
	
	var tween: Tween = create_tween().set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "good_cam_zoom", Vector2(game.default_camera_zoom, game.default_camera_zoom), 2.5)
	
	await get_tree().create_timer(2.5).timeout
	
	finished.emit()
	queue_free()

func _process(delta: float) -> void:
	camera.zoom = good_cam_zoom
