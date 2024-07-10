class_name HUD extends Node2D


var player_field: NoteField
var opponent_field: NoteField
var game: Game

var scroll_direction: StringName = &'up':
	set(value):
		scroll_direction = value
		_set_scroll_direction(value)
var centered_receptors: bool = false:
	set(value):
		centered_receptors = value
		_set_centered_receptors(value)


func _ready() -> void:
	if is_instance_valid(Game.instance):
		game = Game.instance
	else:
		process_mode = Node.PROCESS_MODE_DISABLED
		return
	
	game.ready_post.connect(_ready_post)
	Conductor.beat_hit.connect(_on_beat_hit)
	Conductor.measure_hit.connect(_on_measure_hit)


## This function is called by [Game] at the point where
## things like the hud skin are loaded into the game.
##
## This is useful when using those attributes in your script.
## So yeah.
func setup() -> void:
	pass


func _ready_post() -> void:
	pass


func _on_beat_hit(beat: int) -> void:
	pass


func _on_measure_hit(measure: int) -> void:
	pass


func _on_note_hit(note: Note) -> void:
	pass


func _on_note_miss(note: Note) -> void:
	pass


func _set_scroll_direction(value: StringName) -> void:
	pass


func _set_centered_receptors(value: bool) -> void:
	pass
