class_name Chart extends Resource


var notes: Array[NoteData] = []
var events: Array[EventData] = []


func _to_string() -> String:
	return 'Chart(notes: %s, events: %s)' % [notes, events]
