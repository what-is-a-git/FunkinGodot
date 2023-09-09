extends LineEdit

@onready var charter = $"../../../"

func _ready():
	text = str(charter.song.speed)

func update_speed(_text):
	charter.song.speed = float(text)
