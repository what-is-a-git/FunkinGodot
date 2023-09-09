extends AnimatedSprite2D

var left: bool = false
@onready var cover: Sprite2D = $'../Cover'

func _ready() -> void:
	Conductor.connect("beat_hit", Callable(self, "dance"))

func dance() -> void:
	left = not left
	
	if left:
		play("danceLeft")
	else:
		play("danceRight")

func _process(delta: float) -> void:
	# var shader_material
	if Input.is_action_pressed("ui_right"):
		cover.visible = true
		material.set("shader_parameter/uTime", material.get("shader_parameter/uTime") + (delta * 0.1))
	if Input.is_action_pressed("ui_left"):
		cover.visible = true
		material.set("shader_parameter/uTime", material.get("shader_parameter/uTime") - (delta * 0.1))
