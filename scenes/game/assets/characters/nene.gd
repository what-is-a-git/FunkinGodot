extends Character


@onready var speakers: AnimateSymbol = $speakers
@onready var eye_whites: ColorRect = $eye_whites
@onready var eyes: AnimateSymbol = $eyes
@onready var background: ColorRect = $background



func _ready() -> void:
	super()
	if not is_instance_valid(Game.instance):
		return
	
	await Game.instance.ready_post
	eye_whites.material = speakers.material
	eyes.material = speakers.material
	background.material = speakers.material
