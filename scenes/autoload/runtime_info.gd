extends CanvasLayer


@onready var label: Label = $label
@onready var version: String = ProjectSettings.get_setting('application/config/version', 'Unknown')

var video_memory_peak: float = 0.0
var static_memory_peak: float = 0.0


func display() -> void:
	var video_memory_current: float = Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED)
	
	if video_memory_current > video_memory_peak:
		video_memory_peak = video_memory_current
	
	var static_memory_current: float = Performance.get_monitor(Performance.MEMORY_STATIC)
	
	if static_memory_current > static_memory_peak:
		static_memory_peak = static_memory_current
	
	label.text = '%s FPS (%.2fms)\n%s / %s (GPU)\n%s / %s (CPU)\nFunkin\' Godot v%s' % [
		Performance.get_monitor(Performance.TIME_FPS),
		Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0,
		String.humanize_size(video_memory_current), String.humanize_size(video_memory_peak),
		String.humanize_size(static_memory_current), String.humanize_size(static_memory_peak),
		version,
	]
	
	if OS.is_debug_build():
		label.text = '%s\n%s nodes (%s orphans)' % [
			label.text,
			Performance.get_monitor(Performance.OBJECT_NODE_COUNT),
			Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT),
		]
