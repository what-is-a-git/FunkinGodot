class_name Stage extends Node

@export var camera_zoom: float = 1.05

@export var player_camera_offset: Vector2 = Vector2.ZERO
@export var opponent_camera_offset: Vector2 = Vector2.ZERO

@onready var game: Gameplay = $'../'
