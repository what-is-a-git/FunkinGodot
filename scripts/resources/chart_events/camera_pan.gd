class_name CameraPan extends EventData


func _init(new_time: float, side: Side) -> void:
	name = &'Camera Pan'
	data.push_back(side)
	time = new_time


enum Side {
	PLAYER = 0,
	OPPONENT = 1,
	GIRLFRIEND = 2,
}
