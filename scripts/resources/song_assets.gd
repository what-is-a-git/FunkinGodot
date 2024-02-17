class_name SongAssets extends Resource


@export_category('Characters')

@export var player: PackedScene = null
@export var opponent: PackedScene = null
@export var spectator: PackedScene = null

@export_category('Misc')

@export var stage: PackedScene = null
@export var scripts: Array[PackedScene] = []


func _to_string() -> String:
	return 'SongAssets(player: %s, opponent: %s, spectator: %s, stage: %s)' \
			% [player, opponent, spectator, stage]
