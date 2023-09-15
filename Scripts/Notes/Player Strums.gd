class_name Strumline extends Node2D

@export var is_player: bool = true

var key_count: int = Globals.key_count

@onready var game: Gameplay = $"../../../"

@export var disabled: bool = false

@onready var player_notes = $"../Player Notes"
@onready var bot: bool = Settings.get_data("bot")
@onready var voices: AudioStreamPlayer = AudioHandler.get_node("Voices")

var is_singing_player: bool = true

func _process(delta: float) -> void:
	if bot and is_player and not disabled:
		for note in player_notes.get_children():
			if Conductor.songPosition < note.strum_time or note.been_hit:
				continue
			
			if note.should_hit:
				var strum = note.strum
				
				if game.bf and game.bf.play_singing_animations and note.play_hit_animations:
					game.bf.timer = 0.0
					
					if note.character != 0:
						game.bf.play_animation("sing" + Globals.dir_to_animstr(note.direction).to_upper(), true, note.character)
					else:
						game.bf.play_animation("sing" + Globals.dir_to_animstr(note.direction).to_upper(), true)
				
				if not note.being_pressed:
					game.combo += 1
					game.health += 0.035
					game.popup_rating(note.strum_time)
				
				if not note.is_sustain:
					Globals.emit_signal("player_note_hit", note, note.note_data, note.name, note.character)
					Globals.emit_signal("note_hit", note, note.note_data, note.name, note.character, true)
					
					note.note_hit()
					note.queue_free()
				else:
					Globals.emit_signal("player_note_hit", note, note.note_data, note.name, note.character)
					Globals.emit_signal("note_hit", note, note.note_data, note.name, note.character, true)
					
					note.note_hit()
					
					note.sustain_length -= Conductor.songPosition - note.strum_time
					note.being_pressed = true
					note.been_hit = true
				
				is_singing_player = note.is_singing_player
				strum.play_animation("static")
				strum.play_animation("confirm")
				
				voices.volume_db = 0
			else:
				note.queue_free()
	elif is_player and not disabled:
		for index in key_count:
			var input_string: String = "gameplay_" + str(index)
			var strum: Node2D = get_child(index)
			
			if game.bf and is_singing_player and Input.is_action_pressed(input_string):
				game.bf.timer = 0.0
			if not Input.is_action_pressed(input_string):
				strum.play_animation("static")
				
				for note in player_notes.get_children():
					if note.note_data == index:
						if note.is_sustain and note.sustain_length > Conductor.timeBetweenSteps / 3:
							note.being_pressed = false

func _unhandled_key_input(event: InputEvent) -> void:
	if bot or disabled or (not is_player):
		return

	var can_hit:Array = []

	for note in player_notes.get_children():
		if Conductor.songPosition < -Conductor.safeZoneOffset:
			break
		if not note.been_hit:
			if note.strum_time > Conductor.songPosition - (Conductor.safeZoneOffset * note.hitbox_multiplier) and note.strum_time < Conductor.songPosition + (Conductor.safeZoneOffset * note.hitbox_multiplier):
				can_hit.append(note)

	for index in key_count:
		var input_string:String = "gameplay_" + str(index)
		var strum = get_child(index)
		
		if Input.is_action_just_pressed(input_string):
			strum.play_animation("press")
			
			if can_hit.is_empty():
				continue
			
			var time: float = 0.0
			var lowest_strum: float = INF
			var hit: Node2D = null
			
			for note in can_hit:
				if note.note_data == index and note.strum_time - Conductor.songPosition <= lowest_strum:
					lowest_strum = note.strum_time - Conductor.songPosition
					hit = note
			
			if hit != null:
				if not 'should_hit' in hit:
					hit.should_hit = true
				
				if hit.character != 0:
					if game.bf and game.bf.play_singing_animations and hit.play_hit_animations:
						game.bf.play_animation("sing" + Globals.dir_to_animstr(hit.direction).to_upper(), true, hit.character)
				else:
					if game.bf and game.bf.play_singing_animations and hit.play_hit_animations:
						game.bf.play_animation("sing" + Globals.dir_to_animstr(hit.direction).to_upper(), true)
				
				if hit.should_hit:
					game.combo += 1
				else:
					game.misses += 1
					game.combo = 0
					game.health -= hit.hit_damage
				
				time = hit.strum_time
				
				hit.note_hit()
				
				Globals.emit_signal("player_note_hit", hit, hit.note_data, hit.name, hit.character)
				Globals.emit_signal("note_hit", hit, hit.note_data, hit.name, hit.character, true)
				
				if not hit.is_sustain:
					hit.queue_free()
				else:
					hit.being_pressed = true
					hit.been_hit = true
				
				strum.play_animation("confirm")
				
				hit.sustain_length -= Conductor.songPosition - hit.strum_time
				
				if hit.should_hit:
					game.popup_rating(hit.strum_time)
				else:
					game.total_notes += 1
					
					game.score -= 10
					
					game.update_gameplay_text()
					game.update_rating_text()
				
				is_singing_player = hit.is_singing_player
				voices.volume_db = 0
			
			for note in can_hit:
				if note.note_data == index:
					if note.strum_time == time and note != hit:
						if !note.is_sustain:
							note.note_hit()
							note.queue_free()
						else:
							note.being_pressed = true
							note.been_hit = true
