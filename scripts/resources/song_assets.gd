class_name SongAssets extends Resource


@export var player: PackedScene = null
@export var opponent: PackedScene = null
@export var spectator: PackedScene = null
@export var stage: PackedScene = null


func _to_string() -> String:
	return 'SongAssets(player: %s, opponent: %s, spectator: %s, stage: %s)' \
			% [player, opponent, spectator, stage]
