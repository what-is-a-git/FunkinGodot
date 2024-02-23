## A class that handles the audio tracks for a given
## in-game song, managing their timing and sync,
## as well as generally loading them.
class_name Tracks extends Node


## Name is self explanatory but its measured in seconds.
const MINIMUM_DESYNC_ALLOWED: float = 0.010

var playing: bool = false

var _tracks: Array[AudioStreamPlayerEX] = []
var _playing: Array[bool] = []

signal finished


## Loads the audio tracks from the song [param song]
## and places them into this Node as separate [AudioStreamPlayerEX]s.
func load_tracks(song: StringName, song_path: String = '') -> void:
	if song_path.is_empty():
		song_path = 'res://songs'
	
	# Shouldn't be an issue but just to be sure.
	if song_path.ends_with('/'):
		song_path = song_path.left(song_path.length() - 1)
	
	var tracks: SongTracks = load('%s/%s/tracks.tres' % [song_path, song])
	
	if not tracks:
		printerr('ERROR: Couldn\'t find a meta.tres for song "%s" at song_path "%s"' \
				% [song, song_path])
		return
	
	var index: int = 1
	
	for track in tracks.tracks:
		var stream_player := AudioStreamPlayerEX.new()
		stream_player.stream = track.stream
		stream_player.bus = track.bus
		stream_player.name = 'track_%s' % index
		stream_player.volume_db = linear_to_db(track.volume)
		stream_player.looping = 1
		add_child(stream_player)
		
		var playing_index: int = index - 1
		stream_player.finished.connect(func():
			_playing[playing_index] = false)
		
		_tracks.push_back(stream_player)
		_playing.push_back(false)
		index += 1


## Plays all tracks from position [param from_position].
func play(from_position: float = 0.0) -> void:
	playing = true
	
	var i: int = 0
	
	for track in _tracks:
		track.play(from_position)
		_playing[i] = true
		i += 1


## Checks the sync of all tracks and resyncs them if they
## are out of sync with each other.
func check_sync(force: bool = false) -> void:
	if _tracks.is_empty():
		return
	
	var last_time: float = Conductor.time
	var track_index: int = 0
	var first_track := _tracks[track_index]
	
	while track_index + 1 <= _tracks.size() - 1 and not first_track.playing:
		track_index += 1
		first_track = _tracks[track_index]
	
	var target_time := first_track.get_playback_position()
	var any_desynced: bool = force or \
			absf(target_time - Conductor.time + Conductor.offset) >= 0.05
	
	if not any_desynced:
		for track in _tracks:
			if track == first_track:
				continue
			
			var desync: float = absf(target_time - track.get_playback_position())
			if desync > MINIMUM_DESYNC_ALLOWED:
				any_desynced = true
				break
	
	if not any_desynced:
		return
	
	for track in _tracks:
		if not track.playing:
			continue
		if track == first_track:
			continue
		
		track.seek(target_time)
	
	Conductor.time = target_time + AudioServer.get_time_since_last_mix() + Conductor.offset
	Conductor.beat += (Conductor.time - last_time) * Conductor.beat_delta


## Gets the playback position (factoring in offset) from the track specified.
func get_playback_position(track: int = 0) -> float:
	if _tracks.is_empty() or track < 0 or not playing:
		return Conductor.time
	
	return _tracks[track].get_playback_position() + \
			AudioServer.get_time_since_last_mix() + Conductor.offset


## Sets the playback position of all tracks and Conductor.time to the position
## specified.
func set_playback_position(position: float) -> void:
	if _tracks.is_empty() or not playing:
		return
	
	for track in _tracks:
		track.seek(position)
	
	var last_time: float = Conductor.time
	Conductor.time = position + Conductor.offset
	Conductor.beat += (Conductor.time - last_time) * Conductor.beat_delta


func _physics_process(delta: float) -> void:
	if playing:
		check_sync()
	
	if playing and not _playing.has(true):
		process_mode = Node.PROCESS_MODE_DISABLED
		finished.emit()
