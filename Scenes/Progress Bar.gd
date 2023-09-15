@icon('res://Assets/Images/Godot/Icons/funkin_progress_bar.png')
class_name FunkinProgressBar extends Node2D

@onready var bar: ProgressBar = $ProgressBar
@onready var text: Label = $Text

@onready var inst: AudioStreamPlayer = AudioHandler.get_node('Inst')

@onready var song: String = Globals.song.song
@onready var difficulty: String = Globals.songDifficulty.to_upper()

@onready var bot: bool = Settings.get_data('bot')

func _ready() -> void:
	modulate = Color.TRANSPARENT
	visible = true
	
	var tween: Tween = create_tween().set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, 'modulate:a', 1.0, 0.5 / Globals.song_multiplier) \
			.set_delay(((Conductor.timeBetweenBeats / 1000.0) * 4) / Globals.song_multiplier)
	
	_set_time_text()

func _physics_process(delta: float) -> void:
	if Conductor.songPosition >= 0:
		bar.value = inst.get_playback_position() / inst.stream.get_length()
	
	_set_time_text()

func _set_time_text() -> void:
	if not inst.stream:
		return
	
	text.text = '%s - %s (%s / %s) %s' % [song, difficulty, \
			Globals.format_time(inst.get_playback_position() / Globals.song_multiplier), \
			Globals.format_time(inst.stream.get_length() / Globals.song_multiplier), \
			'(BOT)' if bot else '']
