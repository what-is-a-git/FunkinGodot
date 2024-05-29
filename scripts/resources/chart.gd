class_name Chart extends Resource


var notes: Array[NoteData] = []
var events: Array[EventData] = []


func _to_string() -> String:
	return 'Chart(notes: %s, events: %s)' % [notes, events]


static func load_song(name: StringName, difficulty: StringName) -> Chart:
	name = name.to_lower()
	difficulty = difficulty.to_lower()
	
	var chart: Chart = null
	var base_path: String = 'res://songs/%s' % name
	var legacy_exists: bool = FileAccess.file_exists('%s/charts/%s.json' % [base_path, difficulty])
	
	if legacy_exists:
		var path := '%s/charts/%s.json' % [base_path, difficulty]
		var funkin := FunkinLegacyChart.new()
		var json := FileAccess.get_file_as_string(path)
		funkin.json = JSON.parse_string(json)
		Game.scroll_speed = funkin.json.song.get('speed', 2.6)
		chart = funkin.parse()
		return chart
	
	var fnfc_exists: bool = FileAccess.file_exists('%s/charts/chart.json' % [base_path]) and \
			FileAccess.file_exists('%s/charts/meta.json' % [base_path])
	
	if fnfc_exists:
		var path_chart := '%s/charts/chart.json' % [base_path]
		var path_meta := '%s/charts/meta.json' % [base_path]
		var fnfc := FNFCChart.new()
		var json_chart := FileAccess.get_file_as_string(path_chart)
		var json_meta := FileAccess.get_file_as_string(path_meta)
		fnfc.json_chart = JSON.parse_string(json_chart)
		fnfc.json_meta = JSON.parse_string(json_meta)
		
		if fnfc.json_chart.scrollSpeed is float:
			Game.scroll_speed = fnfc.json_chart.scrollSpeed
		else:
			if fnfc.json_chart.scrollSpeed.has(difficulty.to_lower()):
				Game.scroll_speed = fnfc.json_chart.scrollSpeed.get(difficulty.to_lower(), 2.6)
			else:
				Game.scroll_speed = fnfc.json_chart.scrollSpeed.get('default', 2.6)
		
		chart = fnfc.parse(difficulty)
		return chart
	
	printerr('Chart of song %s with difficulty %s not found.' % [name, difficulty])
	return chart
