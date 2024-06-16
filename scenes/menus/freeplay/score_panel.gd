extends Panel


@onready var score_label: Label = $score_label
@onready var misses_label: Label = $misses_label
@onready var accuracy_label: Label = $accuracy_label
@onready var rank_label: Label = $rank_label

static var toggled: bool = false
const LERP_SPEED: float = 6.0


func _ready() -> void:
	if toggled:
		_process(1.0 / LERP_SPEED)


func _process(delta: float) -> void:
	# 264 = 256 + 8, because we can't use expand margins anymore
	size.x = lerpf(size.x, 264.0 * float(toggled), delta * LERP_SPEED)
	position.x = 1280.0 - size.x


func _input(event: InputEvent) -> void:
	if event.is_echo():
		return
	if not event.is_pressed():
		return
	if event.is_action('freeplay_toggle_score'):
		toggled = not toggled


func refresh(data: Dictionary) -> void:
	score_label.text = 'Score: %s' % data.get('score', 'N/A')
	misses_label.text = 'Misses: %s' % data.get('misses', 'N/A')
	rank_label.text = 'Rank: %s' % data.get('rank', 'N/A')
	
	if data.get('accuracy', 'N/A') is String:
		accuracy_label.text = 'Accuracy: %s' % data.get('accuracy', 'N/A')
	else:
		accuracy_label.text = 'Accuracy: %.3f%%' % data.get('accuracy')
