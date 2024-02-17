class_name FreeplaySong extends Resource


@export var song_name: StringName = &''
@export var song_difficulties: PackedStringArray = [&'easy', &'normal', &'hard',]
@export var icon: Icon = Icon.new()

@export_category('Advanced')
@export var difficulty_remap: DifficultyMap = DifficultyMap.new()

var song_meta: SongMetadata
