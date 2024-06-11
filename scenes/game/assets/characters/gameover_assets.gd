class_name GameoverAssets extends Resource


@export var on_death: AudioStream
@export var looping_music: AudioStream
@export_range(0.0, 1000.0, 0.01, 'or_greater') var music_bpm: float = 100.0
@export var retry: AudioStream
