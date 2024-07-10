class_name SongAssets extends Resource


@export_category('Art')

@export var player: PackedScene = null
@export var spectator: PackedScene = null
@export var opponent: PackedScene = null

@export var stage: PackedScene = null

@export var hud: PackedScene = null
@export var hud_skin: HUDSkin = null

@export_category('Misc')

@export var tracks: AudioStreamSynchronized = null
@export var scripts: Array[PackedScene] = []


func _to_string() -> String:
	return 'SongAssets(player: %s, opponent: %s, spectator: %s, stage: %s, tracks: %s, scripts: %s)' \
			% [player, opponent, spectator, stage, tracks, scripts]
