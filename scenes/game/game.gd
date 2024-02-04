class_name Game extends Node2D


static var chart: Chart = null
static var scroll_speed: float = 3.3

## Each note type is stored here for use in any note field.
static var note_types: Dictionary = {}
static var instance: Game = null

@onready var tracks: Tracks = $tracks
@onready var _default_note := load('res://scenes/game/notes/note.tscn')
var _event: int = 0

signal event_hit(event: EventData)


func _ready() -> void:
	instance = self
	GlobalAudio.get_player('MUSIC').stop()
	
	tracks.load_tracks('philly_nice')
	
	if not chart:
		var funkin_chart := FunkinChart.new()
		funkin_chart.json = JSON.parse_string(\
				FileAccess.get_file_as_string('res://songs/philly_nice/charts/hard.json'))
		chart = funkin_chart.parse()
	
	chart.notes.sort_custom(func(a, b):
		return a.time < b.time)
	
	note_types.clear()
	note_types['default'] = _default_note.instantiate()
	
	tracks.play()
	Conductor.reset()
	
	# Sets the initial bpm. :)
	if not chart.events.is_empty() and \
			chart.events[0].name.to_lower() == 'bpm change':
		_on_event_hit(chart.events[0])
		_event += 1


func _process(delta: float) -> void:
	if not is_instance_valid(chart):
		return
	
	while _event < chart.events.size() and \
			Conductor.time >= chart.events[_event].time:
		var event := chart.events[_event]
		
		_on_event_hit(event)
		event_hit.emit(event)
		_event += 1


func _on_event_hit(event: EventData):
	match event.name.to_lower():
		&'bpm change':
			Conductor.bpm = event.data[0]
		_:
			pass
