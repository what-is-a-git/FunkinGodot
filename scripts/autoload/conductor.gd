extends Node


var bpm: float = 0.0

var beat: float = 0.0
var beat_delta: float = 0.0:
	get:
		return bpm / 60.0

var step: float = 0.0:
	get:
		return beat * 4.0

var measure: float = 0.0:
	get:
		return beat / 4.0

var time: float = 0.0
var target_audio: AudioStreamPlayer = null
var _target_audio_last_time: float = INF

var rate: float = 1.0

var active: bool = true

var audio_offset: float:
	get: return -AudioServer.get_output_latency()
var manual_offset: float = 0.0
var offset: float = audio_offset + manual_offset

var _last_mix: float = 0.0
var _resync_latency: bool = false

var default_input_zone: float = 0.18

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
			offset = audio_offset + manual_offset
		
		_last_mix = mix_time
	
	var last_step: int =  floor(step)
	var last_beat: int =  floor(beat)
	var last_measure: int =  floor(measure)
	
	if target_audio:
		var last_time: float = time
		var audio_position: float = target_audio.get_playback_position()
		var new_time: float = audio_position + \
				AudioServer.get_time_since_last_mix() + offset
		
		if audio_position < _target_audio_last_time:
			_target_audio_last_time = audio_position
			last_time = offset
			time = offset
		
		# bit hacky but it works! :3
		if new_time > last_time:
			time = new_time
			beat += (time - last_time) * beat_delta
			_target_audio_last_time = audio_position
	else:
		time += delta * rate
		beat += delta * rate * beat_delta
	
	if floor(step) > last_step:
		step_hit.emit(floor(step))
	if floor(beat) > last_beat:
		beat_hit.emit(floor(beat))
	if floor(measure) > last_measure:
		measure_hit.emit(floor(measure))


func _on_scene_changed() -> void:
	_resync_latency = Config.get_value('sound', 'recalculate_output_latency')


func _on_config_value_changed(section: String, key: String, value: Variant) -> void:
	if section == 'gameplay' and key == 'manual_offset':
		manual_offset = value / 1000.0


func reset() -> void:
	offset = audio_offset - manual_offset
	beat = 0.0
	time = offset
	target_audio = null
	_target_audio_last_time = INF
