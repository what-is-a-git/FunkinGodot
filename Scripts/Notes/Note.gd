class_name Note extends Node2D

@export var direction: String = 'left'
@export var note_data: int = 0

@export var strum_time: float = 0.0

var strum_y: float = 0.0
var is_player: bool = false

var being_pressed: bool = false
var been_hit: bool = false
var is_sustain: bool = false
var sustain_length: float = 0.0
var og_sustain_length: float = 0.0

var time_held: float = 0.0

@onready var game: Node2D = $"../../../"

@onready var line: Line2D = $Line2D

var held_sprites: Dictionary = Globals.held_sprites

var character: int = 0

var strum: Node2D

@onready var opponent_note_glow: bool = Settings.get_data('opponent_note_glow')
@onready var downscroll: bool = Settings.get_data('downscroll')

@onready var hitsounds: bool = Settings.get_data('hitsounds')

@onready var new_sustain_animations: bool = Settings.get_data('new_sustain_animations')

@onready var animated_sprite = $AnimatedSprite2D

var is_alt: bool = false

# use if multiple textures
@export var custom_sus_path: String

# use if only one texture lmao
@export var single_held_texture: Texture2D
@export var single_end_held_texture: Texture2D

# custom properties
@export var hit_damage: float = 0.0
@export var hit_sustain_damage: float = 0.0

@export var miss_damage: float = 0.07

@export var should_hit: bool = true
@export var cant_miss: bool = false

@export var hitbox_multiplier: float = 1.0 # (float, 0.01, 1.0, 0.01)
@export var play_hit_animations: bool = true
@export var is_singing_player: bool = true

# other shit

@onready var player_strums: Node2D = $'../../Player Strums'
@onready var enemy_strums: Node2D = $'../../Enemy Strums'

@onready var voices: AudioStreamPlayer = AudioHandler.get_node('Voices')

var dad_anim_player: AnimationPlayer
var bf_anim_player: AnimationPlayer

var note_frames: SpriteFrames

@onready var note_render_style: String = Settings.get_data('note_render_style')
@onready var line_2d: Line2D = $Line2D

func _ready() -> void:
	play_animation('')
	
	if note_render_style == 'manual' and animated_sprite is AnimatedSprite2D:
		note_frames = animated_sprite.frames
		animated_sprite.queue_free()
		animated_sprite = null

func set_held_note_sprites() -> void:
	if custom_sus_path:
		held_sprites = {}
		
		for texture in Globals.held_sprites:
			if not texture in held_sprites:
				held_sprites[texture] = []
			
			held_sprites[texture][0] = load('%s%s hold0000.png' % [custom_sus_path, texture])
			held_sprites[texture][1] = load('%s%s hold end0000.png' % [custom_sus_path, texture])
	elif single_held_texture and single_end_held_texture:
		held_sprites = {}
		
		for texture in Globals.held_sprites:
			if not texture in held_sprites:
				held_sprites[texture] = []
			
			held_sprites[texture].push_back(single_held_texture)
			held_sprites[texture].push_back(single_end_held_texture)

func play_animation(anim: String, force: bool = true):
	if animated_sprite is AnimatedSprite2D:
		if force or animated_sprite.frame == animated_sprite.animation.length():
			animated_sprite.play(direction + anim)

func _process(delta: float) -> void:
	if og_sustain_length == 0:
		og_sustain_length = sustain_length if is_sustain else -1
		line.visible = is_sustain
	
	if strum == null:
		strum = player_strums.get_child(note_data) if is_player else \
				enemy_strums.get_child(note_data)
	
	var multiplier: float = -1 if downscroll else 1
	
	if is_sustain:
		if being_pressed:
			if animated_sprite:
				animated_sprite.visible = false
			
			sustain_length -= (delta * 1000.0) * Globals.song_multiplier
			
			var sustain_animation_wait: float = 0.15
			
			if game.dad:
				if new_sustain_animations:
					if !is_player:
						dad_anim_player = game.dad.get_node('AnimationPlayer')
						
						if not 'is_group_char' in game.dad:
							if dad_anim_player.current_animation_length < 0.15:
								sustain_animation_wait = dad_anim_player.current_animation_length
					else:
						bf_anim_player = game.bf.get_node('AnimationPlayer')
						
						if not 'is_group_char' in game.bf:
							if bf_anim_player.current_animation_length < 0.15:
								sustain_animation_wait = bf_anim_player.current_animation_length
			
			if !is_player:
				if opponent_note_glow:
					strum.play_animation('confirm', true)
				
				var good: bool = false
				
				if game.dad and play_hit_animations:
					dad_anim_player = game.dad.get_node('AnimationPlayer')
					
					var animation_player: AnimationPlayer = game.dad.get_child(character).get_node("AnimationPlayer") \
							if "is_group_char" in game.dad and character <= game.dad.get_child_count() - 3 \
							else dad_anim_player
					
					good = animation_player.get_current_animation_position() >= sustain_animation_wait
				else:
					good = true
				
				if not new_sustain_animations:
					good = true
				
				if good:
					if game.dad and play_hit_animations:
						var sing_animation: String = 'sing%s%s' % [Globals.dir_to_animstr(direction).to_upper(), \
								'-alt' if is_alt else '']
						
						if character != 0:
							game.dad.play_animation(sing_animation, true, character)
						else:
							game.dad.play_animation(sing_animation, true)
						
						game.dad.timer = 0
					elif game.dad and not play_hit_animations:
						note_hit()
					
					voices.volume_db = 0
			else:
				var good: bool = false
				
				if time_held >= 0.15:
					good = true
					time_held = 0
				
				var sing_animation: String = 'sing%s' % [Globals.dir_to_animstr(direction).to_upper()]
				
				if game.bf and play_hit_animations:
					if good or not new_sustain_animations:
						if character != 0:
							game.bf.play_animation(sing_animation, true, character)
						else:
							game.bf.play_animation(sing_animation, true)
					
						game.bf.timer = 0
				elif game.bf and not play_hit_animations:
					var last_hitsounds: bool = hitsounds
					hitsounds = false
					
					note_hit()
					
					hitsounds = last_hitsounds
				
				if good:
					strum.play_animation('confirm' if should_hit else 'press', true)
					voices.volume_db = 0
					game.health += 0.02 if should_hit else -hit_sustain_damage
		
		var y_pos: float = ((sustain_length / 1.5) * Globals.scroll_speed) / scale.y
		y_pos -= held_sprites[direction][1].get_height()
		
		line.points[1].y = y_pos * multiplier
		
		if sustain_length <= 0.0:
			queue_free()
		else:
			time_held += delta * Globals.song_multiplier
			queue_redraw()

	strum_y = strum.global_position.y
	modulate.a = strum.modulate.a
	
	global_position.x = strum.global_position.x
	global_position.y = strum_y if being_pressed else \
			strum_y - (
				(0.45 * (Conductor.songPosition - strum_time) * Globals.scroll_speed) \
				* multiplier)
	
	visible = global_position.y > -100.0 and global_position.y < 820.0

func _draw() -> void:
	if note_render_style == 'manual' and (not being_pressed) and note_frames:
		var texture: Texture2D = note_frames.get_frame(direction, 0)
		draw_texture_rect(texture, Rect2(\
				Vector2(texture.get_width() * -0.5, texture.get_height() * -0.5), \
				texture.get_size()), false)
	
	if not is_sustain:
		return
	
	var multiplier: float = -1.0 if downscroll else 1.0
	var end_texture: Texture2D = held_sprites[direction][1]
	
	# the funny thing that controls end note position (and size)
	var rect: Rect2 = Rect2(Vector2(-25.0, 0.0), Vector2(50.0, 0.0))
	rect.size.y = end_texture.get_height() * multiplier * line.scale.y
	rect.size.x *= line.scale.x
	rect.position.x *= line.scale.x
	rect.position.y = line.points[1].y + (rect.size.y if downscroll else 0.0)
	
	if line.points[1].y * multiplier < 0.0:
		rect.size.y -= abs(line.points[1].y) * multiplier
		
		if not downscroll:
			rect.position.y += abs(line.points[1].y)
	
	draw_texture_rect(end_texture, rect, false, line.default_color)
	
	if line.points[1].y * multiplier < 0:
		line.points[1].y = 0

func note_hit() -> void:
	if is_player and hitsounds:
		AudioHandler.play_audio("Hitsound")
	
	pass

func note_miss() -> void:
	pass
