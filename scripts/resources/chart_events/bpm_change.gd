class_name BPMChange extends EventData


func _init(new_time: float, bpm: float) -> void:
	name = &'BPM Change'
	data.push_back(bpm)
	time = new_time
