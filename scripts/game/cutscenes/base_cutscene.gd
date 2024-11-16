## Extension of [FunkinScript] for making cutscenes.
## 
## General helper class to provide some helpful
## built-ins for making song cutscenes.
## This class is only a base for other cutscenes
## and their scripts however, so it won't do much
## on its own.
class_name BaseCutscene extends FunkinScript


func _ready() -> void:
	super()
	game.hud.pause_countdown = true


## Call this function to free this node and allow
## the game to start the countdown.
func finish() -> void:
	game.hud.pause_countdown = false
	queue_free()
