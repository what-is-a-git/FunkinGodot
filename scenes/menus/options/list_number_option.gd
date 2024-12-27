extends Option


@export var section: StringName = &'performance'
@export var key: StringName = &'fps_cap'
@export var list: Array[float] = [0.0]
@export var display_float: bool = true

@onready var value_label: Alphabet = $value

var value: float:
	set(new_value):
		if new_value != Config.get_value(section, key):
			Config.set_value(section, key, new_value)
		value = new_value
		value_label.text = str(value) if display_float else str(int(value))


func _ready() -> void:
	value = Config.get_value(section, key)


func _select() -> void:
	var index: int = list.find(value)
	if index < 0:
		index = 0
	
	value = list[wrapi(index + 1, 0, list.size())]
	GlobalAudio.get_player(^'MENU/CONFIRM').play()
