@tool
class_name AnimatedSprite extends AnimatedSprite2D


@export var playing: bool = false:
	set(value):
		playing = value
		
		if playing:
			play(animation)
		else:
			pause()
