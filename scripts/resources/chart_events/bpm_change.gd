class_name BPMChange extends EventData


func _init(time: float, bpm: float) -> void:
	name = &'BPM Change'
	data.push_back(bpm)
	self.time = time
