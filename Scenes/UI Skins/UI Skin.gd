extends Node
class_name UISkin

### Textures ###
@export var ready_texture: Texture2D = preload("res://Assets/Images/UI/Countdown/ready.png")
@export var set_texture: Texture2D = preload("res://Assets/Images/UI/Countdown/set.png")
@export var go_texture: Texture2D = preload("res://Assets/Images/UI/Countdown/go.png")

@export var health_bar_texture: Texture2D = preload("res://Assets/Images/UI/healthBar.png")

@export var notes_texture: SpriteFrames = preload("res://Assets/Images/Notes/default/default.res")
@export var strums_texture: SpriteFrames = preload("res://Assets/Images/Notes/default/default.res")

### Paths ###
@export var rating_path: String = "res://Assets/Images/UI/Ratings/"
@export var numbers_path: String = "res://Assets/Images/UI/Ratings/"

# Uses this because manually putting each texture in is a pain in the ass #
@export var held_note_path: String = "res://Assets/Images/Notes/default/held/"

### Scaling ##
@export var countdown_scale: float = 1.0

@export var rating_scale: float = 0.7
@export var number_scale: float = 0.6

@export var note_scale: float = 1.0
@export var note_hold_scale: Vector2 = Vector2(1.0, 1.0)
@export var strum_scale: float = 1.0

@export var texture_filter: CanvasItem.TextureFilter = CanvasItem.TEXTURE_FILTER_LINEAR
