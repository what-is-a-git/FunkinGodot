extends Node


func _ready() -> void:
	get_player('MUSIC').stream.loop = true


func get_player(path: NodePath) -> AudioStreamPlayer:
	var player: AudioStreamPlayer = null
	
	if has_node(path):
		player = get_node(path)
	
	return player
