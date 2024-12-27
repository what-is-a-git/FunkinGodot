extends FunkinScript


func _on_event_prepare(event: EventData) -> void:
	if event.name.to_lower() != 'test_event':
		return
	print('Testing preparing event %s!' % event)


func _on_event_hit(event: EventData) -> void:
	if event.name.to_lower() != 'test_event':
		return
	print('You hit event %s!' % event)
