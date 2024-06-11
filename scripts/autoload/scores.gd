extends Node


"""
data dictionary structure:
	{
		"song_name/song_difficulty": {
			"score": 12345,
			"misses": 14,
			"accuracy": 50.4,
			"rank": "D-"
		}
	}

whenever you get a higher
score on a song that is what
replaces the score, even if
your accuracy is lower or misses
are higher or smth
"""

var data: Dictionary


func _ready() -> void:
	data = _load_user_data()
	save()


# Saving and loading file #

func _load_user_data() -> Dictionary:
	if not FileAccess.file_exists('user://scores.res'):
		return {}
	
	var file := FileAccess.open('user://scores.res', FileAccess.READ)
	return file.get_var()


func save() -> void:
	var file := FileAccess.open('user://scores.res', FileAccess.WRITE)
	file.store_var(data)

# Getting and setting scores #

func _get_score_key(song: StringName, difficulty: StringName) -> String:
	return '%s/%s' % [song, difficulty]


func get_score(song: StringName, difficulty: StringName) -> Dictionary:
	return data.get(_get_score_key(song, difficulty), {
			'score': 'N/A',
			'misses': 'N/A',
			'accuracy': 'N/A',
			'rank': 'N/A',
		})


func set_score(song: StringName, difficulty: StringName, score: Dictionary) -> void:
	data[_get_score_key(song, difficulty)] = score
	save()


func reset_score(song: StringName, difficulty: StringName) -> void:
	data.erase(_get_score_key(song, difficulty))
	save()
