extends CanvasLayer


@onready var options: Node2D = %options
@onready var root: Control = $root
@onready var song_label: Label = %song_label
@onready var music: AudioStreamPlayer = $music

var music_volume: float = 0.0
var active: bool = true
var selected: int = 0


func _ready() -> void:
	_change_selection()
	
	root.modulate.a = 0.5
	var tween := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(root, 'modulate:a', 1.0, 0.5)
	
	create_tween().tween_property(self, 'music_volume', 0.9, 2.0).set_delay(0.5)
	
	if not is_instance_valid(Game.instance):
		return
	
	var keys: Array = Game.PlayMode.keys()
	song_label.text = '%s (%s) / %s' % [
		Game.instance.metadata.display_name, Game.difficulty.to_upper(),
		keys[Game.mode].to_upper(),
	]


func _process(delta: float) -> void:
	music.volume_db = linear_to_db(music_volume)


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if not active:
		return
	if not event.is_pressed():
		return
	if event.is_echo():
		return
	
	if event.is_action('ui_down') or event.is_action('ui_up'):
		_change_selection(Input.get_axis('ui_up', 'ui_down'))
	if event.is_action('ui_accept'):
		for option in options.get_children():
			if option.target_y != 0:
				continue
			
			var type: StringName = option.name.to_lower()
			
			match type:
				&'resume':
					_close()
				&'restart':
					_close()
					get_tree().reload_current_scene()
				&'options':
					OptionsMenu.target_scene = 'scenes/game/game.tscn'
					_close()
					SceneManager.switch_to('scenes/menus/options_menu.tscn')
				&'quit':
					_close()
					Game.instance._song_finished(true)
				_:
					printerr('Pause Option %s unimplemented.' % type)


func _change_selection(amount: int = 0) -> void:
	selected = wrapi(selected + amount, 0, options.get_child_count())
	
	if amount != 0:
		GlobalAudio.get_player('MENU/SCROLL').play()
	
	for i in options.get_child_count():
		var option := options.get_child(i)
		option.target_y = i - selected
		option.modulate.a = 1.0 if option.target_y == 0 else 0.6


func _close() -> void:
	active = false
	get_viewport().set_input_as_handled()
	visible = false
	get_tree().paused = false
	queue_free()
	
	if Game.instance.song_started:
		Game.instance.tracks.check_sync(true)
