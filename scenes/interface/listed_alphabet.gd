@tool
class_name ListedAlphabet extends Alphabet


@export var target_y: int = 0
@export var rate: float = 9.6


func _process(delta: float) -> void:
	position = position.lerp(Vector2(
		target_y * 20.0 + 90.0,
		target_y * 1.3 * 120.0 + 360.0 - bounding_box.y * 0.5
	), clampf(delta * rate, 0.0, 1.0))
