class_name DynamicEvent extends EventData



func _init(name_str: StringName, time_val: float, values: Variant) -> void:
	name = name_str
	time = time_val
	data.push_back(values)
