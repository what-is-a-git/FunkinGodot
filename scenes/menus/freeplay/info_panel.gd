extends Node


@export var parent: Node2D

@onready var song_label: Label = $song_label
@onready var difficulty_label: Label = $difficulty_label
@onready var score_label: Label = $score_label
@onready var score_panel: Panel = %score_panel
@onready var reset_panel: Panel = %reset_panel

var song: StringName
var difficulty: StringName
var difficulty_count: int = 0
var score_data: Dictionary
var song_index: int
var song_node: FreeplaySongNode


func _ready() -> void:
	if not is_instance_valid(parent):
		parent = get_tree().current_scene
	
	parent.song_changed.connect(_on_song_changed)
	parent.difficulty_changed.connect(_on_difficulty_changed)


func _on_song_changed(index: int) -> void:
	song_index = index
	song_node = parent.song_nodes[song_index]
	song_label.text = parent.song_nodes[song_index].text


func _on_difficulty_changed(new_difficulty: StringName) -> void:
	var remap := song_node.song.difficulty_remap
	difficulty = new_difficulty
	
	if is_instance_valid(remap) and remap.mapping.has(difficulty):
		song = remap.mapping.get(difficulty)
	else:
		song = song_node.song.song_name
	
	reset_panel.song = song
	reset_panel.difficulty = difficulty
	
	score_data = Scores.get_score(song, difficulty)
	score_panel.refresh(score_data)
	
	if difficulty_count > 1:
		difficulty_label.text = '< %s >' % tr(difficulty.to_lower()).to_upper()
	else:
		difficulty_label.text = '%s' % tr(difficulty.to_lower()).to_upper()
	score_label.text = '%s [TAB]' % score_data.get('score')
