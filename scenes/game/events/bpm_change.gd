extends FunkinScript


func _on_event_hit(event: EventData) -> void:
	super(event)
	if event.name.to_lower() == &'bpm change':
		Conductor.tempo = event.data[0]
