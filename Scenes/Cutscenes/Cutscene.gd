class_name Cutscene extends Node

@onready var game: Gameplay = $"../"

@onready var bf: Character = game.bf
@onready var dad: Character = game.dad
@onready var gf: Character = game.gf

@onready var stage: Node2D = game.stage

@onready var camera: Camera2D = game.camera

signal finished

func _ready() -> void:
	Scenes.current_scene = "Cutscene"
