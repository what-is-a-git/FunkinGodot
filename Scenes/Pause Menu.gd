extends CanvasLayer


var selected: int = 0

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var modulate: CanvasModulate = $Modulate

@onready var selections: Node2D = $Selections

# If the pause menu ever needs changing options, you'll have to update this.
@onready var selection_labels: Array[Node] = selections.get_children()

@onready var scene_tree: SceneTree = get_tree()

@onready var inst: AudioStreamPlayer = AudioHandler.get_node('Inst')
@onready var voices: AudioStreamPlayer = AudioHandler.get_node('Voices')


func _ready() -> void:
	hide()


func _process(delta: float) -> void:
	if not visible:
		return
	
	var i: int = 0
	
	for label in selection_labels:
		Globals.position_menu_alphabet(label, i - selected, delta)
		i += 1


func open() -> void:
	if animation_player.is_playing():
		return
	scene_tree.paused = true
	animation_player.play('open')
	
	inst.stream_paused = true
	voices.stream_paused = true
	selected = 0
	_update_selection()


func close() -> void:
	if animation_player.is_playing():
		return
	scene_tree.paused = false
	animation_player.play('close')
	
	inst.stream_paused = false
	voices.stream_paused = false


func _update_selection() -> void:
	for i in selection_labels.size():
		selection_labels[i].modulate.a = 1.0 if i == selected else 0.5
	
	AudioHandler.play_audio('Scroll Menu')


func _unhandled_key_input(event: InputEvent) -> void:
	if not (event is InputEventKey and visible):
		return
	
	var axis: float = Input.get_axis('ui_up', 'ui_down')
	
	if axis:
		if axis <= -0.75:
			selected = wrapi(selected - 1, 0, selection_labels.size())
		elif axis >= 0.75:
			selected = wrapi(selected + 1, 0, selection_labels.size())
		if absf(axis) >= 0.75:
			_update_selection()
	
	if Input.is_action_just_pressed('ui_confirm'):
		var selection_name: StringName = selection_labels[selected].name
		
		match selection_name.to_lower():
			'resume':
				close()
			'restart song':
				visible = false
				scene_tree.paused = false
				Globals.do_cutscenes = false
				scene_tree.reload_current_scene()
			'options':
				visible = false
				scene_tree.paused = false
				OptionsSideBar.returning_scene = 'Gameplay'
				Scenes.switch_scene('Options Menu')
			'exit menu':
				visible = false
				scene_tree.paused = false
				Scenes.switch_scene('Freeplay' if Globals.freeplay else 'Story Mode')
			_:
				printerr('No supported action for selection %s.' % selection_name)

"""
var selected: int = 0
var showing = false

var tween: Tween

@onready var modulate: CanvasModulate = $Modulate

@onready var resume = $Resume
@onready var restart_song = $"Restart Song"
@onready var options = $"Options"
@onready var exit_menu = $"Exit Menu"

@onready var song_name = $"Song Name"
@onready var song_difficulty = $"Song Difficulty"

func _ready() -> void:
	hide()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_confirm") and Scenes.current_scene == "Gameplay" and !showing:
		get_tree().paused = true
		
		if is_instance_valid(tween) and tween.is_valid():
			tween.stop()
		
		set_pos_text(resume, 0 - selected, 1)
		set_pos_text(restart_song, 1 - selected, 1)
		set_pos_text(options, 2 - selected, 1)
		set_pos_text(exit_menu, 3 - selected, 1)
		
		modulate.a = 0.0
		tween = create_tween().set_trans(Tween.TRANS_QUART).set_parallel()
		tween.tween_property(self, "modulate:a", 1.0, 0.5).set_ease(Tween.EASE_OUT)
		
		song_name.modulate.a = 0
		song_difficulty.modulate.a = 0
		
		song_name.position.y = 10
		song_difficulty.position.y = 40 # 10 + 30
		
		tween.tween_property(song_name, "modulate:a", 1.0, 0.4).set_delay(0.3)
		tween.tween_property(song_name, "position:y", 15, 0.4).set_delay(0.3)
		
		tween.tween_property(song_difficulty, "modulate:a", 1.0, 0.4).set_delay(0.5)
		tween.tween_property(song_difficulty, "position:y", 45, 0.4).set_delay(0.5)
		
		selected = 0
		show()
		on_show()
		showing = true
		refresh_bullshit()
		
		song_name.position.x = 1280 - (song_name.size.x + 20)
		song_difficulty.position.x = 1280 - (song_difficulty.size.x + 20)
		
		AudioHandler.get_node("Inst").stream_paused = true
		AudioHandler.get_node("Voices").stream_paused = true
	elif Input.is_action_just_pressed("ui_confirm") and showing:
		get_tree().paused = false
		hide()
		showing = false
		AudioHandler.get_node("Inst").stream_paused = false
		AudioHandler.get_node("Voices").stream_paused = false
		
		match(selected):
			1:
				get_tree().reload_current_scene()
				Globals.do_cutscenes = false
			2:
				OptionsSideBar.returning_scene = 'Gameplay'
				Scenes.switch_scene('Options Menu')
			3:
				if Globals.freeplay:
					Scenes.switch_scene("Freeplay")
				else:
					Scenes.switch_scene("Story Mode")
	
	if showing:
		set_pos_text(resume, 0 - selected, delta)
		set_pos_text(restart_song, 1 - selected, delta)
		set_pos_text(options, 2 - selected, delta)
		set_pos_text(exit_menu, 3 - selected, delta)
		
		if Input.is_action_just_pressed("ui_down") or Input.is_action_just_pressed("ui_up"):
			if Input.is_action_just_pressed("ui_down"):
				selected += 1
			if Input.is_action_just_pressed("ui_up"):
				selected -= 1
			
			selected = wrapi(selected, 0, 4)
			
			AudioHandler.play_audio("Scroll Menu")
			refresh_bullshit()

func on_show():
	song_name.text = Globals.song.song
	song_difficulty.text = Globals.song_difficulty.to_upper()

func refresh_bullshit():
	resume.modulate.a = 0.5
	restart_song.modulate.a = 0.5
	options.modulate.a = 0.5
	exit_menu.modulate.a = 0.5
	
	match(selected):
		0:
			resume.modulate.a = 1
		1:
			restart_song.modulate.a = 1
		2:
			options.modulate.a = 1
		3:
			exit_menu.modulate.a = 1

func set_pos_text(text, targetY, elapsed):
	var scaledY: float = remap(targetY, 0, 1, 0, 1.3)
	var lerpVal: float = clampf(elapsed * 9.6, 0.0, 1.0)
	
	# 120 = yMult, 720 = FlxG.height
	text.position.y = lerp(text.position.y, (scaledY * 120.0) + (720 * 0.48), lerpVal);
	text.position.x = lerp(text.position.x, (targetY * 20.0) + 90, lerpVal)
"""
