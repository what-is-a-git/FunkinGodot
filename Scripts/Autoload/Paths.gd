extends Node

func scene_path(path):
	return "res://Scenes/" + path + ".tscn"

func stage_path(stage):
	return "res://Scenes/Stages/" + stage + ".tscn"

func song_path(song, difficulty):
	return "res://Assets/Songs/" + song.to_lower() + "/" + difficulty.to_lower() + ".json"

func base_song_path(song):
	return "res://Assets/Songs/" + song.to_lower() + "/"

func char_path(character):
	return "res://Scenes/Characters/" + character + ".tscn"

#func inst_path(song, difficulty):
	

# this shit is barely even used lmao
