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
	
	var event_objects = data.get('eventObjects', null)
	
	if event_objects != null:
		# disclaimer: this does NOT help the camera pans, but at least
		# everything else is accurate for now :]
		for object in event_objects:
			if object.get('type', '').to_lower() != 'bpm change':
				continue
			
			var beat_delta: float = bpm / 60.0
			var last_beat: float = beat
			beat = object.get('position', -1.0)
			time += (beat - last_beat) / beat_delta
			bpm = object.get('value', -1.0)
			chart.events.push_back(BPMChange.new(time, bpm))
		
		beat = 0.0
		time = 0.0
		bpm = data.bpm
	else:
		chart.events.push_back(BPMChange.new(time, bpm))
	
	chart.events.push_back(CameraPan.new(time, must_hit))
	
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
	
	var index: int = 0
	var last_note: NoteData = null
	var stacked_notes: int = 0
	
	chart.notes.sort_custom(func(a: NoteData, b: NoteData):
		return a.time < b.time)
	
	while (not chart.notes.is_empty()) and index < chart.notes.size():
		var note: NoteData = chart.notes[index]
		
		if not is_instance_valid(last_note):
			index += 1
			last_note = note
			continue
		
		if last_note.direction == note.direction and \
				absf(last_note.time - note.time) <= 0.001:
			chart.notes.remove_at(index)
			stacked_notes += 1
			continue
		
		last_note = note
		index += 1
	
	print('Loaded FunkinChart(%s) with %s stacked notes detected.' % [
		data.song, stacked_notes
	])
	
	return chart
