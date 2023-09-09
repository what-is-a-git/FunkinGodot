extends Cutscene

# line stuff
@export var sections: Array = []
var cur_section: int = 0
var frame_timer: float = 0.0

# onready
@onready var text: RichTextLabel = $Text

@onready var bf_port = $BF
@onready var dad_port = $Senpai
@onready var box = $DialogueBox
@onready var hand = $Hand

@onready var bg: ColorRect = $BG

@onready var canvas_modulate: CanvasModulate = $CanvasModulate

@onready var char_click: AudioStreamPlayer = $"Character Sound"
@onready var click_sound: AudioStreamPlayer = $"Click Sound"

var tween: Tween

# maybe use a timer node???
var bg_timer: float = 0.0

func _ready():
	update_text(false)

func _process(delta):
	bg_timer += delta
	
	if bg_timer >= 0.83:
		bg_timer = 0
		bg.color.a += (1.0 / 5.0) * 0.7
		
		if bg.color.a > 0.7:
			bg.color.a = 0.7
	
	if cur_section != -1:
		frame_timer += delta
		
		if frame_timer >= 0.04:
			if text.visible_characters + 1 <= len(text.text):
				text.visible_characters += 1
				char_click.play(0)
				frame_timer = 0
				hand.visible = false
			else:
				hand.visible = true
		
		if Input.is_action_just_pressed("ui_accept"):
			if len(sections) > cur_section + 1:
				update_text(true)
			else:
				click_sound.play(0)
				
				cur_section = -1
				
				if is_instance_valid(tween) and tween.is_valid():
					tween.stop()
				
				tween = create_tween().set_parallel()
				tween.tween_property(canvas_modulate, "color:a", 0.0, 1.2)
				tween.tween_property($Music, "volume_db", -12.0, 1.2)
				
				await get_tree().create_timer(1.2, false).timeout
				
				finished.emit()
				queue_free()

func update_text(update_section: bool = true) -> void:
	if update_section:
		cur_section += 1
		click_sound.play(0)
	
	var cur_section_data:Dictionary = sections[cur_section]
	
	text.text = cur_section_data.text
	text.visible_characters = 0
	frame_timer = 0
	
	box.play("appear")
	box.frame = 0
	
	if cur_section_data.side.to_lower() == "bf":
		bf_port.visible = true
		dad_port.visible = false
	else:
		bf_port.visible = false
		dad_port.visible = true
	
	hand.visible = false
