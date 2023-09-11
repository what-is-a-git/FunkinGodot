extends AnimatedSprite2D

var pressed: bool = false
var stop_shit: bool = false

var timer: float = 0.0

@onready var flash: Node2D = $'../Flash'
@onready var flash_rect: ColorRect = flash.get_node('ColorRect')

func _ready() -> void:
	play('idle')

func _process(delta: float) -> void:
	if Input.is_action_just_pressed('ui_accept') and not pressed:
		if not stop_shit:
			play('pressed')
			AudioHandler.play_audio('Confirm Sound')
			pressed = true
			
			flash.visible = true
			flash_rect.color = Color.WHITE
			var tween := create_tween()
			tween.tween_property(flash_rect, 'color:a', 0.0, \
				AudioHandler.get_node('Confirm Sound').stream.get_length())
		else:
			stop_shit = false
	
	if pressed and not stop_shit:
		if Settings.get_data('flashingLights'):
			timer += delta
		else:
			if timer >= 0.0:
				timer = AudioHandler.get_node('Confirm Sound').stream.get_length() + 0.1
		
		if timer > AudioHandler.get_node('Confirm Sound').stream.get_length():
			switch_to_menu()
		
func switch_to_menu() -> void:
	Scenes.switch_scene('Main Menu')
	timer = -1000.0
