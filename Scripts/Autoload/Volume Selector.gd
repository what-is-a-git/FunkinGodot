extends Node2D

# volume db lol
var volume: int = 0
var muted: bool = false

# used for the animation that moves thing upwards
var timer: float = 1.0

@onready var volume_obj: Node2D = $"CanvasLayer/Volume"
@onready var ui: CanvasLayer = $CanvasLayer

var tweens: Array[Tween] = []

func _ready() -> void:
	for child in volume_obj.get_children():
		tweens.push_back(null)
	
	volume = Settings.get_data("volume")
	muted = Settings.get_data("muted")
	_update_bars(volume, 0.0)

func _process(delta: float) -> void:
	timer += delta if timer < 0.0 else delta * 4.0
	
	if Input.is_action_just_pressed("volume_down"):
		volume = clamp(volume - 5, -50, 0)
		
		if volume == -50:
			muted = true
		
		timer = -1.0
		
		Settings.set_data("volume", volume)
		Settings.set_data("muted", muted)
		_update_bars(volume)
		AudioHandler.play_audio('Volume Down')
	if Input.is_action_just_pressed("volume_up"):
		volume = clamp(volume + 5, -50, 0)
		
		muted = false
		timer = -1.0
		
		Settings.set_data("volume", volume)
		Settings.set_data("muted", muted)
		_update_bars(volume)
		AudioHandler.play_audio('Volume Up')
	if Input.is_action_just_pressed("volume_switch"):
		muted = !muted
		timer = -1.0
		
		Settings.set_data("muted", muted)
		_update_bars(volume)
		AudioHandler.play_audio('Volume Switch')
	if timer <= 1.0:
		ui.offset.y = -60 * clamp(timer, 0, 1)
	else:
		ui.offset.y = -60
	
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), volume)
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), muted)

func _get_volume_percent(volume: float) -> float:
	return (100.0 + (volume * 2.0)) / 10.0

func _update_bars(volume: float, duration: float = 0.25) -> void:
	for child in volume_obj.get_children():
		var child_active: bool = child.name.to_float() <= _get_volume_percent(volume) and not muted
		var target_alpha: float = 1.0 if child_active else 0.35
		
		if child.color.a != target_alpha:
			_tween_child(child, target_alpha, duration)

func _tween_child(child: ColorRect, alpha: float, duration: float = 0.25) -> void:
	var tween: Tween = tweens[child.name.to_int() - 1]
	
	if tween != null and tween.is_valid():
		tween.kill()
	
	tween = create_tween().set_trans(Tween.TRANS_QUAD)
	tweens[child.name.to_int() - 1] = tween
	
	tween.tween_property(child, 'color:a', alpha, duration)
