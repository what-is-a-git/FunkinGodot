extends Node2D

@onready var runner: AnimatedSprite2D = $Runner

var animation_notes: Array = []

func _ready() -> void:
	if Globals.song_name.to_lower() != "stress":
		queue_free()
	else:
		randomize()
		
		remove_child(runner)
		
		var file: FileAccess = FileAccess.open("res://Assets/Songs/stress/picospeaker.json", FileAccess.READ)
		
		var test_json_conv = JSON.new()
		test_json_conv.parse(file.get_as_text())
		var data: Dictionary = test_json_conv.get_data().song
		
		for section in data.notes:
			for note in section.sectionNotes:
				animation_notes.append(note)
		
		animation_notes.sort_custom(Callable(self, "note_sort"))

func _process(delta: float) -> void:
	for i in len(animation_notes):
		if len(animation_notes) - 1 >= i:
			if Conductor.songPosition >= animation_notes[i][0] - 5000:
				if randf_range(0, 100) <= 16:
					var new_tankman = runner.duplicate()
					new_tankman.strum_time = animation_notes[i][0]
					new_tankman.set_values(500, 200 + randf_range(50, 100), animation_notes[i][1] < 2)
					add_child(new_tankman)
				
				animation_notes.erase(animation_notes[i])
			else:
				break

func note_sort(a, b):
	return a[0] < b[0]
