extends LineEdit

@onready var charter: Node2D = $"../../../"

func update_stuff() -> void:
	charter.song.notes[charter.selected_section].bpm = float(text)
