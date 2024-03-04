extends CanvasLayer


@onready var label: Label = $label
@onready var version: String = ProjectSettings.get_setting('application/config/version', 'Unknown')

var video_memory_peak: float = 0.0
var texture_memory_peak: float = 0.0
var static_memory_peak: float = 0.0


func display() -> void:
	if not visible:
		return
	
	var video_memory_current: float = Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED)
	
	if video_memory_current > video_memory_peak:
		video_memory_peak = video_memory_current
	
	var texture_memory_current: float = Performance.get_monitor(Performance.RENDER_TEXTURE_MEM_USED)
	
	if texture_memory_current > texture_memory_peak:
		texture_memory_peak = texture_memory_current
	
	var static_memory_current: float = Performance.get_monitor(Performance.MEMORY_STATIC)
	
	if static_memory_current > static_memory_peak:
		static_memory_peak = static_memory_current
	
	var scene_name: StringName = &'N/A'
	var current_scene := get_tree().current_scene
	
	if is_instance_valid(current_scene):
		scene_name = current_scene.name.to_pascal_case()
	
	label.text = '%s FPS (%.2fms)\n%s / %s <GPU>\n%s / %s <TEX>\nFunkin\' Godot v%s\n%s\n%.2fms Offset\n%.2fms Conductor\n%s Draw Calls (%s Drawn Objects)' % [
		Performance.get_monitor(Performance.TIME_FPS),
		Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0,
		String.humanize_size(video_memory_current), String.humanize_size(video_memory_peak),
		String.humanize_size(texture_memory_current), String.humanize_size(texture_memory_peak),
		version,
		scene_name,
		AudioServer.get_output_latency() * 1000.0, absf(Conductor.offset) * 1000.0,
		Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),
		Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME),
	]
	
	if OS.is_debug_build():
		label.text = '%s\n\n== DEBUG INFO ==\n%s / %s <CPU>\n%s Nodes (%s Orphaned)' % [
			label.text,
			String.humanize_size(static_memory_current), String.humanize_size(static_memory_peak),
			Performance.get_monitor(Performance.OBJECT_NODE_COUNT),
			Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT),
		]


func _input(event: InputEvent) -> void:
	if event.is_action('toggle_debug') and event.is_pressed():
		visible = not visible
		
		if visible:
			display()
