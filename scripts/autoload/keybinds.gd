extends Node


func _ready() -> void:
	Config.value_changed.connect(_on_value_changed)
	update_bindings()


func update_bindings() -> void:
	var binds: Array = Config.get_value('gameplay', 'binds')
	
	for i in binds.size():
		var action := &'input_%s' % i
		var action_events := InputMap.action_get_events(action)
		InputMap.action_erase_event(action, action_events[action_events.size() - 1])
		
		var key: Key = binds[i]
		var event := InputEventKey.new()
		event.keycode = key
		InputMap.action_add_event(action, event)


func _on_value_changed(section: String, key: String, value: Variant) -> void:
	if section != 'gameplay' and key != 'binds':
		return
	
	update_bindings()
