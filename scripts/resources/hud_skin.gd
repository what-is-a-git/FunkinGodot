class_name HUDSkin extends Resource


@export_category('Ratings')

@export var marvelous: Texture2D = preload('res://resources/images/game/skins/default/ratings/marvelous.png')
@export var sick: Texture2D = preload('res://resources/images/game/skins/default/ratings/sick.png')
@export var good: Texture2D = preload('res://resources/images/game/skins/default/ratings/good.png')
@export var bad: Texture2D = preload('res://resources/images/game/skins/default/ratings/bad.png')
@export var shit: Texture2D = preload('res://resources/images/game/skins/default/ratings/shit.png')
@export var rating_scale: float = 0.7

@export_category('Combo')

## It is expected there are images 0-9.png in this folder as they will be
## all preloaded by default.
@export var combo_atlas: Texture2D = preload('res://resources/images/game/skins/default/combo/numbers.png')
@export var combo_scale: float = 0.7
