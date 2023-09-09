extends AnimatedSprite

@onready var tankAngle = floor(randf_range(-90, 45))
@onready var tankSpeed = floor(randf_range(5, 7))

func _ready():
	randomize()

var time:float = 0

func _process(delta):
	time += delta
	
	var tankX = 400
	
	tankAngle = tankAngle + (delta * tankSpeed)
	
	rotation_degrees = tankAngle - 90 + 15
	
	position.x = tankX + 1500 * cos(PI / 180 * (tankAngle + 180))
	position.y = 1300 + 1100 * sin(PI / 180 * (tankAngle + 180))
