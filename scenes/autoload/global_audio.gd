extends Node


func get_player(path: NodePath) -> AudioStreamPlayer:
	var player: AudioStreamPlayer = null
	
	if has_node(path):
		player = get_node(path)
	
	return player
