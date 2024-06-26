## Simple cutscene that plays a video with a
## [VideoStreamPlayer] and then lets you play.
class_name VideoCutscene extends BaseCutscene


## Whether or not to hide the game and its hud
## while the video is playing.
@export var hide_game: bool = true

## Whether or not to allow players to skip the
## cutscene by pressing enter or space (action ui_accept).
@export var allow_skipping: bool = true

@onready var _video_player: VideoStreamPlayer = %player


func _ready() -> void:
	super()
	
	_video_player.play()
	
	if hide_game:
		game.visible = false
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


## Frees the cutscene and shows the game again
## if it was previously hidden.
func finish() -> void:
	super()
	
	if hide_game:
		game.visible = true
		game.hud.visible = true
