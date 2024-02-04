class_name FunkinChart extends Resource


var json: Dictionary


func parse() -> Chart:
	var chart := Chart.new()
	var data: Dictionary = json.song
	
	# section stuff
	var bpm: float = data.bpm
	var beat: float = 0.0
	var time: float = 0.0
	
	chart.events.push_back(BPMChange.new(time, bpm))
	
	for section in data.notes:
		var beat_delta: float = bpm / 60.0
		
		for note in section.sectionNotes:
			var note_data := NoteData.new()
			
			note_data.time = float(note[0]) / 1000.0
			note_data.beat = beat + ((note_data.time - time) / beat_delta)
			note_data.direction = int(note[1])
			
			if not section.mustHitSection:
				note_data.direction = (note_data.direction + 4) % 8
			
			note_data.length = clampf(float(note[2]) * 0.001, 0.0, INF)
			note_data.type = &'default'
			
			chart.notes.push_back(note_data)
		
		if section.get('changeBPM', false) and section.get('bpm', -1.0) != bpm:
			bpm = section.get('bpm', -1.0)
			chart.events.push_back(BPMChange.new(time + beat_delta, bpm))
		
		beat += 4.0
		time += beat_delta
	
	return chart
