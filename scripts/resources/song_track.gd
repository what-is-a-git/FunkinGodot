class_name SongTrack extends Resource


@export var stream: AudioStream = null
@export var bus: StringName = &'Music'


func _to_string() -> String:
	return 'SongTrack(stream: %s, bus: %s)' % [stream, bus]
