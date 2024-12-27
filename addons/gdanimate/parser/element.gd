class_name Element extends Resource


enum ElementType {
	SYMBOL = 0,
	SPRITE
}


@export var name: StringName
@export var type: ElementType
@export var transform: Transform2D


func parse_unoptimized(input: Dictionary) -> void:
	transform = Transform2D.IDENTITY
	transform.origin = Vector2(input.get('m30', 0.0), input.get('m31', 0.0))
	transform.x = Vector2(input.get('m00', 1.0), input.get('m01', 0.0))
	transform.y = Vector2(input.get('m10', 0.0), input.get('m11', 1.0))


func parse_optimized(input: Dictionary) -> void:
	if not input.has(15):
		printerr('Invalid Matrix3D')
		return
	
	transform = Transform2D.IDENTITY
	transform.origin = Vector2(input[12], input[13])
	transform.x = Vector2(input[0], input[1])
	transform.y = Vector2(input[4], input[5])
