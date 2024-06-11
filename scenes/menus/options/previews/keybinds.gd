extends Node2D


@onready var keys: Array[Node] = get_children()
var selected: int = -1
var hovering: int = -1


func _ready() -> void:
	var binds: Array = Config.get_value('gameplay', 'binds')
	
	for i in keys.size():
		var key := keys[i]
		key.get_node('key').text = Alphabet.keycode_to_character(binds[i])
		key.modulate.a = 0.6


func _process(delta: float) -> void:
	for key in keys:
		if key.editor_description.is_empty():
			key.editor_description = '0.6'
		
		key.modulate.a = lerpf(key.modulate.a, float(key.editor_description),
				delta * 9.0)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_handle_motion(event)
	if event is InputEventMouseButton:
		_handle_button(event)
	if event is InputEventKey and selected != -1:
		_handle_key(event)


func _handle_key(event: InputEventKey):
	# set config
	var binds: Array = Config.get_value('gameplay', 'binds').duplicate()
	binds[selected] = event.keycode
	Config.set_value('gameplay', 'binds', binds)
	
	# set display
	var key := keys[selected]
	key.get_node('key').text = Alphabet.keycode_to_character(event.keycode)
	key.editor_description = '0.6'
	
	# reset selected
	selected = -1


func _handle_motion(event: InputEventMouseMotion) -> void:
	if selected != -1:
		return
	
	hovering = -1
	
	for i in keys.size():
		var key: Node2D = keys[i]
		var key_rect: Rect2 = Rect2(key.global_position.x - 50.0,
				key.global_position.y - 50.0,
				100.0, 100.0,)
		if key_rect.has_point(event.global_position):
			key.editor_description = '1.0'
			hovering = i
		else:
			key.editor_description = '0.6'


func _handle_button(event: InputEventMouseButton) -> void:
	if hovering == -1:
		return
	if not event.pressed:
		return
	
	selected = hovering