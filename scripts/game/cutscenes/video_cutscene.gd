## Simple cutscene that plays a video with a
## [VideoStreamPlayer] and then lets you play.
class_name VideoCutscene extends BaseCutscene

signal on_video_ended()

## Whether or not to hide the game and its hud
## while the video is playing.
@export var hide_game: bool = true

## Whether or not to allow players to skip the
## cutscene by pressing enter or space (action ui_accept).
@export var allow_skipping: bool = true

## Whether to autoplay the video once its stream is set
@export var autoplay: bool = true

## The file to play the video with, must be a FFMpegVideoStream.
@export var file: String:
	set(new_file):
		stream.file = new_file
		if stream.file:
			_video_player.stream = stream
			if autoplay: play(true)
		file = new_file

@onready var _video_player: VideoStreamPlayer = %player

var stream: FFmpegVideoStream = FFmpegVideoStream.new()

func _ready() -> void:
	super()
	if _video_player.stream: _video_player.play()
	if game and hide_game:
		game.visible = false
		if game is Game:
			game.hud.visible = false


func _input(event: InputEvent) -> void:
	if not allow_skipping:
		return
	if event.is_echo():
		return
	if not event.is_pressed():
		return
	if event.is_action('ui_accept'):
		finish()

## Plays the video if it isn't already playing.[br]
## [param]force[/param] To force the video to play regardless of whether it is already.
func play(force: bool = false) -> void:
	if _video_player.is_playing():
		if not force: return
		_video_player.stop()
	_video_player.show()
	_video_player.play()

## Frees the cutscene and shows the game again
## if it was previously hidden.
func finish() -> void:
	super()
	if _video_player.is_playing():
		_video_player.stop()
	_video_player.hide()
	on_video_ended.emit()
	if game and hide_game:
		game.visible = true
		if game is Game:
			game.hud.visible = true
