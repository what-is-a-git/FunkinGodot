class_name CameraPan extends EventData


func _init(new_time: float, side: int) -> void:
	name = &'Camera Pan'
	data.push_back(side)
	time = new_time