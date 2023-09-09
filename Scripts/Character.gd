class_name Character extends Node2D

@export var camOffset: Vector2 = Vector2(0,0)
@export var danceLeftAndRight: bool = false
@export var health_bar_color: Color = Color(1,0,0,1)
@export var health_icon: Texture2D = preload("res://Assets/Images/Icons/bf-icons.png")
@export var dances: bool = true
@export var death_character: String = "bf-dead"

var danceLeft = false
var play_singing_animations: bool = true
var special_anim: bool = false

var timer: float = 0.0

var last_anim:String = ""

var anim_player:AnimationPlayer
var anim_sprite:AnimatedSprite2D

func _ready() -> void:
	anim_player = $AnimationPlayer
	anim_sprite = $AnimatedSprite2D
	
	if dances:
		dance(true)

func _process(delta):
	if dances:
		if last_anim != "idle" and !last_anim.begins_with("dance"):
			timer += delta * Globals.song_multiplier
			
			var multiplier:float = 4
			
			if name.to_lower() == "dad":
				multiplier = 6.1
			
			if timer >= Conductor.timeBetweenSteps * multiplier * 0.001:
				if anim_player.current_animation == "" or anim_player.current_animation.begins_with("sing") or anim_player.get_animation(anim_player.current_animation).loop_mode != 0:
					dance(true)
					timer = 0.0

func play_animation(animation, _force = true, _character:int = 0):
	if name == "_":
		return
	
	special_anim = false
	last_anim = animation
	
	if !anim_player:
		anim_player = $AnimationPlayer
		anim_sprite = $AnimatedSprite2D
	
	if anim_player.has_animation(animation):
		anim_player.stop()
		
		if anim_sprite:
			anim_sprite.stop()
		
		if anim_player:
			anim_player.play(animation)

func dance(force = null, alt = null):
	if special_anim and anim_player.current_animation != "":
		return
	
	special_anim = false
	
	var can = false
	
	if last_anim.ends_with("-alt") and alt == null:
		alt = true
	
	if danceLeftAndRight and last_anim.begins_with("dance"):
		force = true
	
	if force == null and danceLeftAndRight:
		can = anim_player.current_animation == "" or anim_player.current_animation.begins_with("dance")
	else:
		can = force or anim_player.current_animation == ""
	
	if can:
		if danceLeftAndRight:
			danceLeft = !danceLeft
				
			if danceLeft:
				play_animation("danceLeft", force)
				
				if alt:
					play_animation("danceLeft-alt", force)
			else:
				play_animation("danceRight", force)
				
				if alt:
					play_animation("danceRight-alt", force)
		else:
			play_animation("idle", force)
			
			if alt:
				play_animation("idle-alt", force)

func is_dancing():
	var dancing = true
	
	if last_anim != "idle" and !last_anim.begins_with("dance"):
		dancing = false
	
	return dancing

func has_anim(anim: String, character: int = -1):
	return anim_player.has_animation(anim)
