extends CanvasLayer


@onready var label: Label = $label
@onready var version: String = ProjectSettings.get_setting('application/config/version', 'Unknown')

var video_memory_peak: float = 0.0
var texture_memory_peak: float = 0.0
var static_memory_peak: float = 0.0
var tween: Tween


func _ready() -> void:
	visible = Config.get_value('performance', 'performance_info_visible')
	
	if OS.is_debug_build():
		get_node('timer').wait_time = 0.2


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
	
	label.size = Vector2.ZERO
	var text_output: String = \
			'%d FPS (%.2fms)\n%s / %s <GPU>\n%s / %s <TEX>\nFunkin\' Godot v%s' % [
		Performance.get_monitor(Performance.TIME_FPS),
		Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0,
		String.humanize_size(video_memory_current), String.humanize_size(video_memory_peak),
		String.humanize_size(texture_memory_current), String.humanize_size(texture_memory_peak),
		version,
	]
	
	if OS.is_debug_build():
		text_output += '\n\n[Debug]\nScene: %s\n%s / %s <CPU>\n%d Nodes (%d Orphaned)\n\n[Conductor]\n%.2fms AudioServer Offset\n%.2fms Offset (%.2fms manual)\n%.3fs Time\n%.2f Beat, %.2f Step, %.2f Measure\n%.2f BPM\n\n[Rendering]\n%d Draw Calls (%d Drawn Objects)\nAPI: %s' % [
			scene_name,
			String.humanize_size(static_memory_current), String.humanize_size(static_memory_peak),
			Performance.get_monitor(Performance.OBJECT_NODE_COUNT),
			Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT),
			AudioServer.get_output_latency() * -1000.0,
			Conductor.offset * 1000.0,
			Conductor.manual_offset * 1000.0,
			Conductor.time, Conductor.beat, Conductor.step, Conductor.measure,
			Conductor.tempo,
			Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),
			Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME),
			get_rendering_driver()
		]
	
	label.text = text_output


func _input(event: InputEvent) -> void:
	if event.is_action('toggle_debug') and event.is_pressed():
		visible = not visible
		Config.set_value('performance', 'performance_info_visible', visible)
		
		if visible:
			label.modulate.a = 0.5
			
			if is_instance_valid(tween) and tween.is_running():
				tween.kill()
			
			tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
			tween.tween_property(label, 'modulate:a', 1.0, 0.2)
			display()
		else:
			visible = true
			label.modulate.a = 1.0
			
			if is_instance_valid(tween) and tween.is_running():
				tween.kill()
			
			tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
			tween.tween_property(label, 'modulate:a', 0.0, 0.2)
			tween.tween_property(self, 'visible', false, 0.0)


func get_rendering_driver() -> String:
	var version := RenderingServer.get_video_adapter_api_version()
	if version.begins_with('12'):
		return 'D3D12'
	if version.begins_with('3'):
		return 'OpenGL'
	if version.begins_with('1'):
		return 'Vulkan'
	
	return 'Metal'
