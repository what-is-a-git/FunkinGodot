extends Cutscene

@onready var video = $VideoStreamPlayer

func _ready():
	print("STARTING VIDEO")
	
	video.connect("finished", Callable(self, "on_finish"))
	video.play()

func _process(_delta):
	if Input.is_action_just_pressed("ui_accept"):
		video.paused = !video.paused
	
	if Input.is_action_just_pressed("ui_shift"):
		on_finish()
	
	if !video.is_playing():
		on_finish()

func on_finish():
	emit_signal("finished")
	
	print("VIDEO DONE")
	
	queue_free()
