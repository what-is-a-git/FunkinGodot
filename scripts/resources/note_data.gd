class_name NoteData extends Resource


@export var time: float
@export var beat: float
@export var direction: int
@export var length: float

@export var type: StringName


func _to_string() -> String:
	return 'NoteData(time: %s, beat: %s, direction: %s, length: %s, type: %s)' \
			% [time, beat, direction, length, type]
