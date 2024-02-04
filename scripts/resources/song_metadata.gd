class_name SongMetadata extends Resource


@export var display_name: StringName = &'Test'
@export var authors: Array[SongAuthor]
@export var tracks: Array[SongTrack]


func _to_string() -> String:
	return 'SongMetadata(display_name: %s, authors: %s, tracks: %s)' \
			% [display_name, authors, tracks]
