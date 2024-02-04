class_name NoteData extends Resource


var time: float
var beat: float
var direction: int
var length: float

var type: StringName


func _to_string() -> String:
	return 'NoteData(time: %s, beat: %s, direction: %s, length: %s, type: %s)' \
			% [time, beat, direction, length, type]
