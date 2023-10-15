extends Stage


var last_beat: int = 0
var beat_offset: int = 8

@onready var gameplay: Gameplay = get_parent()

@onready var animated_sprite: AnimatedSprite2D = $Background/AnimatedSprite2D

@onready var shaker = $Shaker
@onready var camera: Camera2D = $"../Camera"


func _ready() -> void:
	randomize()
	shaker.camera = camera
	
	Conductor.connect("beat_hit", Callable(self, "beat_hit"))


func beat_hit() -> void:
	var beat: int = Conductor.curBeat
	
	if randf_range(0.0, 100.0) < 10.0 and beat > last_beat + beat_offset:
		last_beat = beat
		
		gameplay.bf.timer = 0.0
		gameplay.bf.play_animation("scared", true)
		
		gameplay.gf.timer = 0.0
		gameplay.gf.play_animation("scared", true)
		
		animated_sprite.play("idle")
		animated_sprite.stop()
		animated_sprite.play("lightning")
		
		beat_offset = randi_range(8, 24)
		
		get_node("Strike " + str(randi_range(1, 2))).play()
		
		shaker.shake(0.005, Conductor.timeBetweenBeats * 0.001)
		camera.zoom += Vector2(0.05, 0.05)
