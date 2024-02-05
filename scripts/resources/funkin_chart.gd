class_name FunkinChart extends Resource


var json: Dictionary


func parse() -> Chart:
	var chart := Chart.new()
	var data: Dictionary = json.song
	
	# section stuff
	var bpm: float = data.bpm
	var beat: float = 0.0
	var time: float = 0.0
	# If your chart is completely empty, you have issues.
	var must_hit: bool = data.notes[0].mustHitSection
	
	chart.events.push_back(BPMChange.new(time, bpm))
	
	for section in data.notes:
		var beat_delta: float = bpm / 60.0
		
		for note in section.sectionNotes:
			if int(note[1]) < 0:
				continue
			
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
			chart.events.push_back(BPMChange.new(time, bpm))
		if section.mustHitSection != must_hit:
			must_hit = section.mustHitSection
			chart.events.push_back(CameraPan.new(time, must_hit))
		
		beat += 4.0
		time += 4.0 / beat_delta
	
	return chart
