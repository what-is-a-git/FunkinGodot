class_name FunkinScript extends Node


var player: Character
var opponent: Character
var spectator: Character
var stage: Stage

var player_field: NoteField
var opponent_field: NoteField


func _ready() -> void:
	Conductor.beat_hit.connect(_on_beat_hit)
	Conductor.step_hit.connect(_on_step_hit)
	Conductor.measure_hit.connect(_on_measure_hit)
	
	if is_instance_valid(Game.instance):
		player = Game.instance.player
		opponent = Game.instance.opponent
		spectator = Game.instance.spectator
		stage = Game.instance.stage
		
		player_field = Game.instance._player_field
		opponent_field = Game.instance._opponent_field
		
		Game.instance.song_start.connect(_on_song_start)


func _on_beat_hit(beat: int) -> void:
	pass


func _on_step_hit(step: int) -> void:
	pass


func _on_measure_hit(measure: int) -> void:
	pass


func _on_song_start() -> void:
	pass
