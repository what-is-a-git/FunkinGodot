extends Stage

var lastBeat = 0
var beatOffset = 8

@onready var gameplay = $"../"

@onready var animated_sprite = $Background/AnimatedSprite2D

@onready var shaker = $Shaker
@onready var camera = $"../Camera"

func _ready():
	randomize()
	shaker.camera = camera
	
	Conductor.connect("beat_hit", Callable(self, "beat_hit"))

func beat_hit():
	var beat = Conductor.curBeat
	
	if randf_range(0, 100) < 10 and beat > lastBeat + beatOffset:
		lastBeat = beat
		
		gameplay.bf.timer = 0.0
		gameplay.bf.play_animation("scared", true)
		
		gameplay.gf.timer = 0.0
		gameplay.gf.play_animation("scared", true)
		
		animated_sprite.play("idle")
		animated_sprite.stop()
		animated_sprite.play("lightning")
		
		beatOffset = rand_int_val(8,24)
		
		get_node("Strike " + str(rand_int_val(1,2))).play()
		
		shaker.shake(0.005, Conductor.timeBetweenBeats / 1000.0)
		camera.zoom += Vector2(0.05, 0.05)

func rand_int_val(minimum, maximum):
	return round(randf_range(minimum, maximum))
