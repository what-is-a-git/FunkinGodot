class_name SongTrack extends Resource


@export var stream: AudioStream = null
@export var bus: StringName = &'Music'
@export_range(0.0, 2.0, 0.01) var volume: float = 1.0


func _to_string() -> String:
	return 'SongTrack(stream: %s, bus: %s)' % [stream, bus]
