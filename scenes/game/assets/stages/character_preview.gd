@tool
extends Node2D


@export_file('*.tscn') var character_path: String = 'res://scenes/game/assets/characters/bf.tscn':
	set(value):
		character_path = value
		if Engine.is_editor_hint():
			queue_redraw()
@export var flipped: bool = false:
	set(value):
		flipped = value
		if Engine.is_editor_hint():
			queue_redraw()

var character: Node = null


func _ready() -> void:
	if Engine.is_editor_hint():
		queue_redraw()


func _draw() -> void:
	if not Engine.is_editor_hint():
		return
	if not ResourceLoader.exists(character_path):
		return
	if character:
		character.queue_free()
	
	var scene: PackedScene = load(character_path)
	character = scene.instantiate()
	character.modulate.a = 0.5
	if flipped:
		character.scale.x *= -1.0
	add_child(character)
