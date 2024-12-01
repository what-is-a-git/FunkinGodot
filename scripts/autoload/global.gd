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
var was_paused: bool = false


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
	
	var window := get_window()
	window.focus_entered.connect(_on_focus_enter)
	window.focus_exited.connect(_on_focus_exit)


func _on_focus_enter() -> void:
	if not Config.get_value('performance', 'auto_pause'):
		return
	get_tree().paused = false


func _on_focus_exit() -> void:
	if not Config.get_value('performance', 'auto_pause'):
		return
	
	var tree := get_tree()
	was_paused = tree.paused
	tree.paused = true


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_echo():
		return
	if not event.is_pressed():
		return
	if event.is_action('menu_fullscreen'):
		get_viewport().set_input_as_handled()
		fullscreened = not fullscreened
		return
	if not OS.is_debug_build():
		return
	if event.is_action('menu_reload') and is_instance_valid(get_tree().current_scene):
		get_tree().reload_current_scene()
		get_tree().paused = false
		return


static func free_children_from(node: Node, immediate: bool = false) -> void:
	for child: Node in node.get_children():
		if immediate:
			child.free()
		else:
			child.queue_free()
