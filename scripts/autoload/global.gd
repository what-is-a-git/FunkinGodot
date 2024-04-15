extends Node


var fullscreened: bool = false:
	set(value):
		DisplayServer.window_set_mode(
				DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN if value else
				DisplayServer.WINDOW_MODE_WINDOWED)
		fullscreened = value
var game_size: Vector2:
	get:
		return get_viewport().get_visible_rect().size


func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	
	# Clear color without effect in editor.
	RenderingServer.set_default_clear_color(Color.BLACK)
	
	# Slightly faster input latency. (probably)
	Input.use_accumulated_input = false
	
	# Might save a small amount of performance.
	# Shouldn't be detrimental to this game specifically so...
	PhysicsServer2D.set_active(false)
	PhysicsServer3D.set_active(false)


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_echo():
		return
	if not event.is_pressed():
		return
	if event.is_action('menu_fullscreen'):
		get_viewport().set_input_as_handled()
		fullscreened = not fullscreened
		return
	if event.is_action('menu_reload'):
		get_tree().reload_current_scene()
		return
