extends Node2D


@onready var NOTE: PackedScene = load('res://scenes/game/notes/note.tscn')
@onready var notes: NoteField = $notes

var lane: int = 0



func _ready() -> void:
	Conductor.beat_hit.connect(_on_beat_hit)
	notes._force_no_chart = true
	notes._chart = null


func _process(delta: float) -> void:
	Conductor.time = GlobalAudio.music.get_playback_position() \
			+ AudioServer.get_time_since_last_mix() + Conductor.offset
	
	if Conductor.beat >= 4.0:
		Conductor.beat = 0.0
	
	# clean up notes when song restarts
	for note: Note in notes._notes.get_children():
		if note.data.time - Conductor.time >= 4.0:
			note.queue_free()


func _on_beat_hit(beat: int) -> void:
	var note := NOTE.instantiate()
	note.data = NoteData.new()
	note.data.time = Conductor.time + (1.0 / Conductor.beat_delta)
	note.data.beat = float(beat + 1.0)
	note.data.direction = lane
	note.data.length = 0.0
	note.data.type = &'default'
	note.position.x = notes._receptors[0].position.x + 112.0 * lane
	note.position.y = -4000.0
	notes._notes.add_child(note)
	note.lane = lane
	
	lane = wrapi(lane + 1, 0, 4)
