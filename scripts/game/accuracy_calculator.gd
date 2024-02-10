class_name AccuracyCalculator extends Node


@export var accuracy_curve: Curve
var hit_count: int = 0
var total_accuracy: float = 0.0


func record_hit(difference: float) -> void:
	hit_count += 1
	total_accuracy += clampf(
			accuracy_curve.sample(difference / Conductor.default_input_zone),
			0.0,
			1.0)


func get_accuracy() -> float:
	if hit_count > 0:
		return total_accuracy / hit_count * 100.0
	
	return 0.0
