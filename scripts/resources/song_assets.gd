class_name SongAssets extends Resource


@export_category('Art')

@export var player: PackedScene = null
@export var spectator: PackedScene = null
@export var opponent: PackedScene = null

@export var stage: PackedScene = null

@export_category('HUD')

@export var hud: PackedScene = null
@export var hud_skin: HUDSkin = null

@export var player_skin: NoteSkin = null
@export var opponent_skin: NoteSkin = null

@export_category('Misc')

@export var scripts: Array[PackedScene] = []


func _to_string() -> String:
	return 'SongAssets(player: %s, opponent: %s, spectator: %s, stage: %s, scripts: %s)' \
			% [player, opponent, spectator, stage, scripts]
