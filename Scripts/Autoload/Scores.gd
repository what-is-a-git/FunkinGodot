extends Node

var score_file: FileAccess

var song_scores: Dictionary = {}

func _ready():
	if FileAccess.file_exists("user://Scores.json"):
		score_file = FileAccess.open("user://Scores.json", FileAccess.READ)
		
		var test_json_conv = JSON.new()
		test_json_conv.parse(score_file.get_as_text())
		var data = test_json_conv.get_data()
		
		song_scores = data.song_scores
	
	save_to_file()

func save_to_file():
	score_file = FileAccess.open("user://Scores.json", FileAccess.WRITE)
	score_file.store_line(JSON.stringify({
		"song_scores": song_scores
	}))
	
	score_file.close()

func format_song(song, difficulty):
	return song.to_lower() + "_" + difficulty.to_lower()

func set_song_score(song, difficulty, score = 0):
	song_scores[format_song(song, difficulty)] = score
	save_to_file()

func get_song_score(song, difficulty):
	if not format_song(song, difficulty) in song_scores:
		set_song_score(song, difficulty, 0)
	
	return int(song_scores[format_song(song, difficulty)])

func clear_scores():
	song_scores = {}
	
	save_to_file()
