extends AnimatedSprite2D

func _ready() -> void:
	Conductor.connect("beat_hit", Callable(self, "bop"))
	
func bop() -> void:
	frame = 0
	play("idle")

func _process(delta: float) -> void:
	if Input.is_action_pressed("ui_right"):
		material.set("shader_parameter/uTime", material.get("shader_parameter/uTime") + (delta * 0.1))
	if Input.is_action_pressed("ui_left"):
		material.set("shader_parameter/uTime", material.get("shader_parameter/uTime") - (delta * 0.1))
