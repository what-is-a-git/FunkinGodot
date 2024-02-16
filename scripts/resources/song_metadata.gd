class_name SongMetadata extends Resource


@export_category('Display Information')

@export var display_name: StringName = &'Test'
@export var display_color: Color = Color.WHITE

@export_category('Credits')

@export var authors: Array[SongAuthor]

@export_category('Tracks')

@export var tracks: Array[SongTrack]


func _to_string() -> String:
	return 'SongMetadata(display_name: %s, authors: %s, tracks: %s)' \
			% [display_name, authors, tracks]
