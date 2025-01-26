extends Node


var tempo: float = 0.0

var beat: float = 0.0
var beat_delta: float = 0.0:
	get:
		return 60.0 / tempo

var step: float = 0.0:
	get:
		return beat * 4.0

var measure: float = 0.0:
	get:
		return beat / 4.0

var time: float = 0.0
var target_audio: AudioStreamPlayer = null
var target_length: float:
	get:
		if is_instance_valid(target_audio) and is_instance_valid(target_audio.stream):
			return target_audio.stream.get_length()
		
		return -1.0

var rate: float = 1.0
var active: bool = true

var audio_offset: float:
	get: return -AudioServer.get_output_latency()
var manual_offset: float = 0.0
var offset: float = audio_offset - manual_offset

var _last_mix: float = 0.0
var _resync_latency: bool = false

signal step_hit(step: int)
signal beat_hit(beat: int)
signal measure_hit(measure: int)


func _ready() -> void:
	SceneManager.scene_changed.connect(_on_scene_changed)
	Config.value_changed.connect(_on_config_value_changed)
	_on_config_value_changed('gameplay', 'manual_offset', 
			Config.get_value('gameplay', 'manual_offset'))
	_on_scene_changed()


func _process(delta: float) -> void:
	if not active:
		return
	
	if _resync_latency:
		var mix_time: float = AudioServer.get_time_since_last_mix()
		if mix_time < _last_mix:
			reset_offset()
		_last_mix = mix_time
	
	var last_step: int = floori(step)
	var last_beat: int = floori(beat)
	var last_measure: int = floori(measure)
	
	if is_instance_valid(target_audio):
		if not target_audio.playing:
			return
		
		var last_time: float = time
		var audio_position: float = target_audio.get_playback_position() \
				+ AudioServer.get_time_since_last_mix()
		
		if audio_position + offset > time:
			time = audio_position + offset
			beat += (time - last_time) / beat_delta
		elif time >= target_length + offset:
			# stoopid looping fix :3
			time = 0.0
			beat = 0.0
			_process(delta)
			return
	else:
		time += delta * rate
		beat += delta * rate / beat_delta
	
	if floori(step) > last_step:
		for step_value in range(last_step + 1, floori(step) + 1):
			step_hit.emit(step_value)
	if floori(beat) > last_beat:
		for beat_value in range(last_beat + 1, floori(beat) + 1):
			beat_hit.emit(beat_value)
	if floori(measure) > last_measure:
		for measure_value in range(last_measure + 1, floori(measure) + 1):
			measure_hit.emit(measure_value)


func _on_scene_changed() -> void:
	_resync_latency = Config.get_value('sound', 'recalculate_output_latency')


func _on_config_value_changed(section: String, key: String, value: Variant) -> void:
	if section == 'gameplay' and key == 'manual_offset':
		manual_offset = value / 1000.0


func _on_finished() -> void:
	time = 0.0
	beat = 0.0


func reset() -> void:
	reset_offset()
	beat = 0.0
	time = offset
	target_audio = null


func reset_offset() -> void:
	offset = audio_offset - manual_offset
