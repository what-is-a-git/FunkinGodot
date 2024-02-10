class_name RatingsCalculator extends Node


@export var ratings: Array[Rating] = []


func get_rating(difference: float) -> Rating:
	if ratings.is_empty():
		return null
	
	var rating: Rating = ratings[0]
	
	for rating_iter in ratings:
		if difference <= rating_iter.timing:
			rating = rating_iter
		else:
			break
	
	return rating
