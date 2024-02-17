class_name SongMetadata extends Resource


@export_category('Display Information')

@export var display_name: StringName = &'Test'

@export_category('Credits')

@export var authors: Array[SongAuthor]


func _to_string() -> String:
	return 'SongMetadata(display_name: %s, authors: %s)' \
			% [display_name, authors]
