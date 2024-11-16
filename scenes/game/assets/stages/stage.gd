class_name Stage extends Node2D


@onready var game: Game = Game.instance
@export_range(0.01, 4.0, 0.01) var default_zoom: float = 1.05


func _init() -> void:
	Conductor.beat_hit.connect(_on_beat_hit)
	Conductor.step_hit.connect(_on_step_hit)
	Conductor.measure_hit.connect(_on_measure_hit)


func _on_beat_hit(beat: int) -> void:
	pass


func _on_step_hit(step: int) -> void:
	pass


func _on_measure_hit(measure: int) -> void:
	pass
