## A class that handles the audio tracks for a given
## in-game song, managing their timing and sync,
## as well as generally loading them.
class_name Tracks extends Node


## Name is self explanatory but its measured in seconds.
const MINIMUM_DESYNC_ALLOWED: float = 0.010

var playing: bool = false

var _tracks: Array[AudioStreamPlayerEX] = []
var _last_mix_time: float = 0.0

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
		add_child(stream_player)
		
		_tracks.push_back(stream_player)
		index += 1


## Plays all tracks from position [param from_position].
func play(from_position: float = 0.0) -> void:
	playing = true
	
	for track in _tracks:
		track.play(from_position)


## Checks the sync of all tracks and resyncs them if they
## are out of sync with each other.
func check_sync(force: bool = false) -> void:
	if _tracks.is_empty():
		return
	
	var last_time: float = Conductor.time
	var any_desynced: bool = force
	var first_track := _tracks[0]
	var target_time := first_track.get_playback_position()
	
	if not any_desynced:
		for track in _tracks:
			if track == first_track:
				continue
			
			var desync: float = absf(target_time - track.get_playback_position())
			if desync > MINIMUM_DESYNC_ALLOWED:
				any_desynced = true
				break
	
	if not any_desynced:
		if absf(target_time - Conductor.time) >= 0.1:
			Conductor.time = target_time + \
					AudioServer.get_time_since_last_mix() + Conductor.offset
			Conductor.beat += (Conductor.time - last_time) * Conductor.beat_delta
		
		return
	
	for track in _tracks:
		if track == first_track:
			continue
		
		track.seek(target_time)
	
	Conductor.time = target_time + AudioServer.get_time_since_last_mix() + Conductor.offset
	Conductor.beat += (Conductor.time - last_time) * Conductor.beat_delta


func get_playback_position(track: int = 0) -> float:
	if _tracks.is_empty() or track < 0 or not playing:
		return Conductor.time
	
	return _tracks[track].get_playback_position() + \
			AudioServer.get_time_since_last_mix() + Conductor.offset


func set_playback_position(position: float) -> void:
	if _tracks.is_empty() or not playing:
		return
	
	for track in _tracks:
		track.seek(position)
	Conductor.time = position + Conductor.offset


func _physics_process(delta: float) -> void:
	if playing:
		check_sync()
	
	_last_mix_time = AudioServer.get_time_to_next_mix()
	
	var any_playing: bool = false
	
	for track in _tracks:
		if track.playing:
			any_playing = true
			break
	
	if playing and not any_playing:
		finished.emit()
		queue_free()
