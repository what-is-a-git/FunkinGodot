class_name CameraPan extends EventData


func _init(time: float, side: int) -> void:
	name = &'Camera Pan'
	data.push_back(side)
	self.time = time
