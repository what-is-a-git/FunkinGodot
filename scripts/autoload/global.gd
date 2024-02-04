extends Node


var fullscreened: bool = false:
	set(value):
		DisplayServer.window_set_mode(
				DisplayServer.WINDOW_MODE_FULLSCREEN if value else
				DisplayServer.WINDOW_MODE_WINDOWED)
		fullscreened = value


func _ready() -> void:
	# Clear color without effect in editor.
	RenderingServer.set_default_clear_color(Color.BLACK)
	
	# Slightly faster input latency. (probably)
	Input.use_accumulated_input = false
	
	# Might save a small amount of performance.
	# Shouldn't be detrimental to this game specifically so...
	PhysicsServer2D.set_active(false)
	PhysicsServer3D.set_active(false)


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action('menu_fullscreen') and \
			event.is_action_pressed('menu_fullscreen'):
		get_viewport().set_input_as_handled()
		fullscreened = not fullscreened
