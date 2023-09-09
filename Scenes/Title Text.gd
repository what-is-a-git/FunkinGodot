extends Node2D

@onready var text: Label = $Text

var intro_texts: Array = []
var random_text: int

@onready var enter_text: AnimatedSprite2D = $"../Enter Txt"

@onready var godot: Sprite2D = $Godot
@onready var animation_player: AnimationPlayer = $Godot/AnimationPlayer

var tween: Tween

func _ready() -> void:
	if Scenes.startup:
		randomize()
		
		var file := FileAccess.open("res://Assets/intro_text.txt", FileAccess.READ)
		intro_texts = file.get_as_text().split("\n")
		
		random_text = floor(randf_range(0, len(intro_texts)))
		
		Conductor.connect("beat_hit", Callable(self, "beat_hit"))
		
		enter_text.stop_shit = true
	else:
		queue_free()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		intro()

func beat_hit() -> void:
	godot.visible = false
	
	match(Conductor.curBeat):
		1:
			text.text = "leather128"
		3:
			text.text += "\npresents"
		4:
			text.text = ""
		5:
			text.text = "using"
		7:
			text.text += "\ngodot"
			godot.visible = true
			animation_player.play('show_up')
		8:
			text.text = ""
		9:
			text.text = intro_texts[random_text].split("--")[0]
		11:
			text.text += "\n" + intro_texts[random_text].split("--")[1]
		12:
			text.text = ""
		13:
			text.text = "Friday"
		14:
			text.text += "\nNight"
		15:
			text.text += "\nFunkin"
		16:
			intro()

func intro() -> void:
	var flash: Node2D = $"../Flash"
	flash.visible = true
	
	var flash_rect: ColorRect = flash.get_node("ColorRect")
	
	tween = create_tween().bind_node(get_parent())
	tween.tween_property(flash_rect, "color:a", 0.0, \
		AudioHandler.get_node("Confirm Sound").stream.get_length())
	
	queue_free()
	
	enter_text.stop_shit = false
	Scenes.startup = false
