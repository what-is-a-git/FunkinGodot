extends FunkinScript


func _on_event_hit(event: EventData) -> void:
	if event.name.to_lower() != &'playanimation':
		return
	
	var data: Dictionary = event.data[0]
	var target: String = data.get('target', 'bf')
	var animation: String = data.get('anim', 'hey')
	var force: bool = data.get('force', true)
	var character: Character
	match target:
		'bf':
			character = player
		'gf':
			character = spectator
		'dad':
			character = opponent
	if not is_instance_valid(character):
		return
	
	character.play_anim(animation, force, true)
