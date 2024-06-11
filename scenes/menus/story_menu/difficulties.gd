extends Control


@onready var left_arrow: AnimatedSprite = $left_arrow
@onready var right_arrow: AnimatedSprite = $right_arrow
@onready var difficulty: Sprite2D = $difficulty
@onready var animated_difficulty: AnimatedSprite = difficulty.get_node('animated')

static var selected: int = 1
var difficulties: PackedStringArray = []


func _input(event: InputEvent) -> void:
	if event.is_echo():
		return
	if event.is_action('ui_left'):
		left_arrow.play(&'leftConfirm' if event.is_pressed() else &'leftIdle')
	if event.is_action('ui_right'):
		right_arrow.play(&'rightConfirm' if event.is_pressed() else &'rightIdle')


func change_selection(amount: int = 0) -> void:
	selected = wrapi(selected + amount, 0, difficulties.size())
	
	difficulty.visible = not difficulties.is_empty()
	if difficulties.is_empty():
		return
	
	_reload_difficulty_sprite()
	_tween_difficulty_sprite()


func _reload_difficulty_sprite() -> void:
	var path: String = 'res://resources/images/menus/story_menu/difficulty_sprites/%s' \
			% difficulties[selected]
	var is_animated: bool = ResourceLoader.exists('%s.res' % path)
	
	if is_animated:
		animated_difficulty.visible = true
		animated_difficulty.sprite_frames = load('%s.res' % path)
		animated_difficulty.play(&'idle')
		difficulty.self_modulate.a = 0.0
	else:
		animated_difficulty.visible = false
		difficulty.self_modulate.a = 1.0
		difficulty.texture = load('%s.png' % path)


func _tween_difficulty_sprite() -> void:
	difficulty.modulate.a = 0.0
	difficulty.position.y = 132.0 - 25.0
	var tween := create_tween().set_parallel()
	tween.tween_property(difficulty, 'modulate:a', 1.0, 0.07)
	tween.tween_property(difficulty, 'position:y', 132.0, 0.07)
