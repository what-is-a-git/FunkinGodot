extends MainMenuButton


@onready var menu: Node2D = get_tree().current_scene
@onready var timer: Timer = %timer
@onready var background: Sprite2D = %background.get_node(^'sprite')
@onready var background_animations: AnimationPlayer = %background.get_node('animation_player')
@onready var donate: AnimatedSprite = $sprite
@onready var kickstarter: AnimatedSprite = $kickstarter

var active: bool = false
var selected: int = 0
var tween: Tween


func press() -> void:
	timer.stop()
	background_animations.stop()
	kickstarter.visible = true
	
	if is_instance_valid(tween) and tween.is_running():
		tween.kill()
	
	tween = create_tween().set_trans(Tween.TRANS_EXPO)\
			.set_ease(Tween.EASE_OUT).set_parallel()
	tween.tween_property(donate, 'position:x', -300.0, 0.5)
	tween.tween_property(kickstarter, 'position:x', 275.0, 0.5)
	tween.tween_property(background, ^'modulate', Color('#b5a48f'), 0.5)
	active = true


func accept() -> bool:
	return true


func _input(event: InputEvent) -> void:
	if not active:
		return
	if not event.is_pressed():
		return
	if event.is_action('ui_cancel'):
		get_viewport().set_input_as_handled()
		
		active = false
		selected = 0
		change_selection(0)
		GlobalAudio.get_player('MENU/CANCEL').play()
		menu.active = true
		menu._cancel_animation()
		
		if is_instance_valid(tween) and tween.is_running():
			tween.kill()
		
		tween = create_tween().set_trans(Tween.TRANS_EXPO)\
				.set_ease(Tween.EASE_OUT).set_parallel()
		tween.tween_property(donate, 'position:x', 0.0, 0.5)
		tween.tween_property(kickstarter, 'position:x', 0.0, 0.5)
		tween.tween_property(background, ^'modulate', Color.WHITE, 0.5)
		tween.tween_callback(func():
			kickstarter.visible = false).set_delay(0.15)
		return
	if event.is_action('ui_accept'):
		GlobalAudio.get_player('MENU/CONFIRM').play()
		
		match selected:
			0:
				OS.shell_open('https://ninja-muffin24.itch.io/funkin')
			1:
				OS.shell_open('https://kickstarter.com/projects/funkin/friday-night-funkin-the-full-ass-game')
		return
	var horizontal: bool = event.is_action('ui_left') or event.is_action('ui_right')
	var vertical: bool = event.is_action('ui_up') or event.is_action('ui_down')
	if horizontal or vertical:
		if horizontal:
			change_selection(int(roundf(Input.get_axis('ui_left', 'ui_right'))))
		if vertical:
			change_selection(int(roundf(Input.get_axis('ui_up', 'ui_down'))))

func change_selection(amount: int = 0) -> void:
	selected = wrapi(selected + amount, 0, 2)
	match selected:
		0:
			kickstarter.play(&'kickstarter idle')
			kickstarter.scale = Vector2.ONE
			donate.play(&'donate selected')
		1:
			kickstarter.play(&'kickstarter selected')
			kickstarter.scale = Vector2(0.8, 0.8)
			donate.play(&'donate idle')
	
	if amount != 0:
		GlobalAudio.get_player('MENU/SCROLL').play()
