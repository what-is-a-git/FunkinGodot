class_name AccuracyCalculator extends Node


@export var accuracy_curve: Curve
var hits: Array[float] = []


func record_hit(difference: float) -> void:
	hits.push_back(absf(difference) / Conductor.safeZoneOffset)


func record_note_hit(note: Note) -> void:
	record_hit(Conductor.songPosition - note.strum_time)


func get_accuracy() -> float:
	if hits.size() > 0:
		var total_accuracy: float = 0.0
		
		for hit in hits:
			if accuracy_curve == null:
				total_accuracy += 1.0 - hit
			else:
				# print('hit %s // curve %s' % [hit, accuracy_curve.sample(hit)])
				total_accuracy += clampf(accuracy_curve.sample(hit), 0.0, 1.0)
		
		# for i in 100:
		# 	print('VALUE %f // SAMPLED %f' % [i / 100.0, accuracy_curve.sample(i / 100.0)])
		
		# Normalized to 0.0 - 1.0 range.
		return total_accuracy / hits.size()
	
	return 0.0
