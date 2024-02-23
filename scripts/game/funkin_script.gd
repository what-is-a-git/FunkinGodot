class_name FunkinScript extends Node


var game: Game

var player: Character
var opponent: Character
var spectator: Character
var stage: Stage

var player_field: NoteField
var opponent_field: NoteField

var camera: Camera2D


func _ready() -> void:
	Conductor.beat_hit.connect(_on_beat_hit)
	Conductor.step_hit.connect(_on_step_hit)
	Conductor.measure_hit.connect(_on_measure_hit)
	
	if is_instance_valid(Game.instance):
		game = Game.instance
		
		player = game.player
		opponent = game.opponent
		spectator = game.spectator
		stage = game.stage
		
		player_field = game._player_field
		opponent_field = game._opponent_field
		
		camera = game.camera
		game.song_start.connect(_on_song_start)
		game.event_hit.connect(_on_event_hit)
		game.ready_post.connect(_ready_post)


func _ready_post() -> void:
	pass


func _on_beat_hit(beat: int) -> void:
	pass


func _on_step_hit(step: int) -> void:
	pass


func _on_measure_hit(measure: int) -> void:
	pass


func _on_song_start() -> void:
	pass


func _on_event_hit(event: EventData) -> void:
	pass
