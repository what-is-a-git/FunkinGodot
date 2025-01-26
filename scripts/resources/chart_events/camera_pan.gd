class_name CameraPan extends EventData


func _init(new_time: float = 0.0, side: Side = 0) -> void:
	name = &'Camera Pan'
	data.push_back(side)
	time = new_time


enum Side {
	PLAYER = 0,
	OPPONENT = 1,
	GIRLFRIEND = 2,
}
