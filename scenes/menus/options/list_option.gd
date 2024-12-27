extends Option


@export var section: StringName = &'gameplay'
@export var key: StringName = &'scroll_speed_method'
@export var list: Array[String] = ['chart']
@export var display_raw: bool = true

@onready var value_label: Alphabet = $value

var value: String:
	set(new_value):
		if new_value != Config.get_value(section, key):
			Config.set_value(section, key, new_value)
		value = new_value
		value_label.text = value if display_raw else value.replace('_', ' ')


func _ready() -> void:
	value = Config.get_value(section, key)


func _select() -> void:
	var index: int = list.find(value)
	if index < 0:
		index = 0
	
	value = list[wrapi(index + 1, 0, list.size())]
	GlobalAudio.get_player(^'MENU/CONFIRM').play()
