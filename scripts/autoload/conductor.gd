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

var rate: float = 1.0

var active: bool = true
var offset: float = -AudioServer.get_output_latency()

var default_input_zone: float = 0.18

signal on_step_hit(step: int)
signal on_beat_hit(beat: int)
signal on_measure_hit(measure: int)


func _process(delta: float) -> void:
	if not active:
		return
	
	var last_step: int =  floor(step)
	var last_beat: int =  floor(beat)
	var last_measure: int =  floor(measure)
	
	if target_audio:
		var last_time: float = time
		var new_time: float = target_audio.get_playback_position() + \
				AudioServer.get_time_since_last_mix() + offset
		
		# bit hacky but it works! :3
		if new_time > last_time:
			time = new_time
			beat += (time - last_time) * beat_delta
	else:
		time += delta
		beat += delta * beat_delta
	
	if floor(step) > last_step:
		on_step_hit.emit(floor(step))
	if floor(beat) > last_beat:
		on_beat_hit.emit(floor(beat))
	if floor(measure) > last_measure:
		on_measure_hit.emit(floor(measure))


func reset() -> void:
	beat = 0.0
	time = offset
	target_audio = null
