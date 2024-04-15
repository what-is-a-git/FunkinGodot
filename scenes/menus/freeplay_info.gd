extends Node


@export var parent: Node2D

@onready var song_label: Label = $song_label
@onready var difficulty_label: Label = $difficulty_label
@onready var accuracy_label: Label = $accuracy_label


func _ready() -> void:
	if not is_instance_valid(parent):
		parent = get_tree().current_scene


func _on_song_changed(index: int) -> void:
	song_label.text = parent.song_nodes[index].text


func _on_difficulty_changed(difficulty: StringName) -> void:
	difficulty_label.text = '< %s >' % tr(difficulty.to_lower()).to_upper()
