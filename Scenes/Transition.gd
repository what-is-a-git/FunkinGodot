extends CanvasLayer

@onready var anim_player = $AnimationPlayer

func trans_in():
	anim_player.play("in")

func trans_out():
	anim_player.play("out")
