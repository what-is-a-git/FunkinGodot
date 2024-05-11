class_name WeekData extends Resource


@export_category('Data')

@export var songs: PackedStringArray = [&'tutorial']
@export var difficulties: PackedStringArray = [&'easy', &'normal', &'hard']
@export var title: String = 'Teaching Time'

@export_category('Visuals')

@export var texture: Texture
@export var characters: Array[PackedScene] = [null, null, null]
@export var color: Color = Color('f9cf51')

@export_category('Effects')

@export var flashes: bool = true
@export var flash_color: Color = Color.CYAN
