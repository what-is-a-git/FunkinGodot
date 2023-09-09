class_name FunkinScript extends Node


@onready var game: Gameplay = $'../'

@onready var dad: Character = game.dad
@onready var bf: Character = game.bf
@onready var gf: Character = game.gf


func _init() -> void:
	Globals.connect('_ready_post', Callable(self, '_ready_post'))
	Globals.connect('player_note_hit', Callable(self, 'player_note_hit'))
	Globals.connect('enemy_note_hit', Callable(self, 'enemy_note_hit'))
	Globals.connect('note_hit', Callable(self, 'note_hit'))
	Globals.connect('note_miss', Callable(self, 'note_miss'))
	Globals.connect('camera_moved', Callable(self, 'camera_moved'))
	Globals.connect('event_setup', Callable(self, 'event_setup'))
	Globals.connect('_ready_post', Callable(self, '_ready_post'))
	Conductor.connect('beat_hit', Callable(self, 'beat_hit'))
	Conductor.connect('step_hit', Callable(self, 'step_hit'))


func _ready_post() -> void:
	pass


# self explanatory
func player_note_hit(note, dir, type, character) -> void:
	pass


func enemy_note_hit(note, dir, type, character) -> void:
	pass


# must_hit is basically asking if it's a player side note or not btw
func note_hit(note, dir, type, character, must_hit) -> void:
	pass


# called when the player misses a note
func note_miss(note, dir, type, character) -> void:
	pass


# self explanatory
func camera_moved(character) -> void:
	pass


# called every time an event is setup (not sure if this is useful, but better be safe than sorry)
func event_setup(event) -> void:
	pass


# called every time an event is triggered
func event_processed(event) -> void:
	pass


func beat_hit() -> void:
	pass


func step_hit() -> void:
	pass
