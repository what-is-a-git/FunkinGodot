class_name SongAssets extends Resource


@export_category('Characters')

@export var player: PackedScene = preload('res://scenes/game/assets/characters/bf.tscn')
@export var opponent: PackedScene = preload('res://scenes/game/assets/characters/dad.tscn')
@export var spectator: PackedScene = preload('res://scenes/game/assets/characters/gf.tscn')

@export_category('Misc')

@export var stage: PackedScene = preload('res://scenes/game/assets/stages/stage.tscn')


func _to_string() -> String:
	return 'SongAssets(player: %s, opponent: %s, spectator: %s, stage: %s)' \
			% [player, opponent, spectator, stage]
