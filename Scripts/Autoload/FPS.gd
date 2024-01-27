extends CanvasLayer

var vram: float = 0.0
var vram_peak: float = 0.0

var mem: float = 0.0
var mem_peak: float = 0.0

@onready var debug: bool = OS.is_debug_build()
@onready var fps_text: Label = $fps

var timer: Timer = Timer.new()

func _ready() -> void:
	add_child(timer)
	
	timer.start(1.0)
	timer.connect("timeout", Callable(self, "_update"))
	
	_update()


func _update() -> void:
	vram = RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TEXTURE_MEM_USED)
	
	if vram > vram_peak:
		vram_peak = vram
	
	fps_text.text = "%sfps\n%s / %s (gpu)" % [Engine.get_frames_per_second(), \
			Globals.format_bytes(vram), Globals.format_bytes(vram_peak)]
	
	if debug:
		mem = OS.get_static_memory_usage()
		
		if mem > mem_peak:
			mem_peak = mem
		
		fps_text.text += '\n%s / %s (cpu)' % [
			Globals.format_bytes(mem), Globals.format_bytes(mem_peak)]


func _unhandled_key_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed('debug_key'):
		visible = !visible
		
		if not visible:
			timer.paused = true
		else:
			timer.paused = false
			timer.start(1.0)
			_update()
