## A class that handles the audio tracks for a given
## in-game song, managing their timing and sync,
## as well as generally loading them.
class_name Tracks extends Node


## Name is self explanatory but its measured in seconds.
const MINIMUM_DESYNC_ALLOWED: float = 0.010

@onready var player: AudioStreamPlayer = $player
var playing: bool:
	get:
		return player.is_playing()
		
var last_playback_position: float = 0.0

signal finished


func _unloop_track(track: AudioStream) -> void:
	if track is AudioStreamMP3 or track is AudioStreamOggVorbis:
		track.loop = false
	elif track is AudioStreamWAV:
		track.loop_mode = AudioStreamWAV.LOOP_DISABLED
	else:
		printerr('ERROR: Tried to unloop unsupported AudioStream type.')


## Loads the audio tracks from the song [param song]
## and places them into this Node as separate [AudioStreamPlayerEX]s.
func load_tracks(song: StringName, song_path: String = '') -> void:
	if song_path.is_empty():
		song_path = 'res://songs'
	
	# Shouldn't be an issue but just to be sure.
	if song_path.ends_with('/'):
		song_path = song_path.left(song_path.length() - 1)
	
	var tracks: AudioStream = load('%s/%s/tracks.tres' % [song_path, song])
	if not tracks:
		printerr('ERROR: Couldn\'t find a tracks.tres for song "%s" at song_path "%s"' \
				% [song, song_path])
		return
	
	var index: int = 1
	player.stream = tracks
	player.bus = &'Music'
	if tracks is AudioStreamSynchronized:
		for i in tracks.stream_count:
			_unloop_track(tracks.get_sync_stream(i))
	else:
		_unloop_track(tracks)
	
	player.finished.connect(_on_finished)


## Plays all tracks from position [param from_position].
func play(from_position: float = 0.0) -> void:
	player.play(from_position)


## Checks the sync of all tracks and resyncs them if they
## are out of sync with each other.
func check_sync(force: bool = false) -> void:
	if not is_instance_valid(player.stream):
		return
	# With the newer target audio system it's
	# no longer required to resync manually like this.
	if Conductor.target_audio == player:
		return
	
	var last_time: float = Conductor.time
	var track_index: int = 0
	
	var target_time := player.get_playback_position()
	var desync: float = absf(target_time - Conductor.time + Conductor.offset)
	var any_desynced: bool = force or desync >= 0.02
	
	if not any_desynced:
		return
	
	#print('Resynced with %.3fms of desync!%s' % [desync * 1000.0, 
	#		' (forced)' if force else ''])
	Conductor.time = get_playback_position()
	Conductor.beat += (Conductor.time - last_time) * Conductor.beat_delta


## Gets the playback position (factoring in offset) from the track specified.
func get_playback_position() -> float:
	if not is_instance_valid(player.stream) or not player.is_playing():
		return Conductor.time
	
	return player.get_playback_position() + AudioServer.get_time_since_last_mix()\
			 + Conductor.offset


## Sets the playback position of all tracks and Conductor.time to the position
## specified.
func set_playback_position(position: float) -> void:
	if not is_instance_valid(player.stream) or not player.is_playing():
		return
	if position < 0.0:
		position = 0.0
	
	player.seek(position)
	
	var last_time: float = Conductor.time
	Conductor.time = position + Conductor.offset
	Conductor.beat += (Conductor.time - last_time) * Conductor.beat_delta


func _physics_process(delta: float) -> void:
	if playing:
		check_sync()
	elif Game.instance.song_started:
		_on_finished()
	
	last_playback_position = player.get_playback_position()


func _on_finished() -> void:
	player.stop()
	finished.emit()
	process_mode = Node.PROCESS_MODE_DISABLED
