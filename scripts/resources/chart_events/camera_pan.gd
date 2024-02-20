class_name CameraPan extends EventData


func _init(new_time: float, side: bool) -> void:
	name = &'Camera Pan'
	data.push_back(Side.PLAYER if side else Side.OPPONENT)
	time = new_time


enum Side {
	OPPONENT = 0,
	PLAYER = 1,
}
