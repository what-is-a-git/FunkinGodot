@icon('res://Assets/Images/Godot/Icons/accuracy_calculator.png')
class_name AccuracyCalculator extends Node


@export var accuracy_curve: Curve
var hit_count: int = 0
var total_accuracy: float = 0.0


func record_hit(difference: float) -> void:
	hit_count += 1
	total_accuracy += clampf(\
			accuracy_curve.sample(absf(difference) / Conductor.safeZoneOffset),
			0.0,
			1.0)


func get_accuracy() -> float:
	if hit_count > 0:
		return total_accuracy / hit_count
	
	return 0.0
