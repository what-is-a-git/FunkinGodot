extends Character

var animation_notes: Array = []

func _ready() -> void:
	var file := FileAccess.open("res://Assets/Songs/stress/picospeaker.json", FileAccess.READ)
	
	var test_json_conv := JSON.new()
	test_json_conv.parse(file.get_as_text())
	var data: Dictionary = test_json_conv.get_data()["song"]
	
	for section in data.notes:
		for note in section.sectionNotes:
			animation_notes.append(note)
	
	animation_notes.sort_custom(Callable(self, "note_sort"))

func _process(delta: float) -> void:
	while not animation_notes.is_empty() and animation_notes[0][0] <= Conductor.songPosition:
		var shot_direction: int = 1
		
		if animation_notes[0][1] >= 2:
			shot_direction = 3
		
		shot_direction += round(randf_range(0, 1))
		
		play_animation('shoot' + str(shot_direction), true)
		animation_notes.pop_front()
	
	if anim_sprite and anim_sprite.frame >= anim_sprite.sprite_frames.get_frame_count(anim_sprite.animation) - 1:
		if last_anim == "idle":
			last_anim = "shoot2"
		
		anim_sprite.frame = anim_sprite.sprite_frames.get_frame_count(anim_sprite.animation) - 4
		anim_sprite.playing = true

func note_sort(a, b):
	return a[0] < b[0]
