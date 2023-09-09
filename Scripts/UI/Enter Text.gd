extends AnimatedSprite2D

var pressed: bool = false
var stop_shit: bool = false

var timer: float = 0.0

func _ready() -> void:
	play("idle")

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept") and !pressed:
		if !stop_shit:
			play("pressed")
			AudioHandler.play_audio("Confirm Sound")
			pressed = true
		else:
			stop_shit = false
	
	if pressed and !stop_shit:
		if Settings.get_data("flashingLights"):
			timer += delta
		else:
			if timer >= 0.0: timer = AudioHandler.get_node("Confirm Sound").stream.get_length() + 0.1
		
		if timer > AudioHandler.get_node("Confirm Sound").stream.get_length():
			switch_to_menu()
		
func switch_to_menu() -> void:
	Scenes.switch_scene("Main Menu")
	timer = -1000.0
