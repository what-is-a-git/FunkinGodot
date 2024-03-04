## Alternative node type to [ParallaxLayer] and [ParallaxBackground]
## that works independently and doesn't effect it's position based on
## the camera's current zoom.
@icon('res://addons/parallax_node/parallax_node.svg')
class_name ParallaxNode extends Node2D


## Factor by how close the parallax should be to the actual camera
## movement. 1 is exactly the same as no parallax, 0 is static on
## the screen, and 0.5 is like 1 but it moves slower.
@export var parallax_factor: Vector2 = Vector2.ONE

## Whether or not to use the position set for the node on ready
## as an internal offsetting system.
@export var position_as_offset: bool = false

## Whether or not to automatically get the current camera
## every frame, could be beneifical to keep this off in certain
## circumstances, but is on by default for maximum performance.
@export var ignore_camera_changes: bool = true

## Internal variable used to track the current camera.
var _camera: Camera2D
var _offset: Vector2 = Vector2.ZERO


func _ready() -> void:
	_camera = get_viewport().get_camera_2d()
	
	if position_as_offset:
		_offset = position


func _process(delta: float) -> void:
	if not ignore_camera_changes:
		_camera = get_viewport().get_camera_2d()
	
	if _camera == null:
		position = Vector2.ZERO
		return
	
	position = _offset + (_camera.get_screen_center_position() - \
			(get_viewport_rect().size / 2.0)) * (Vector2.ONE - parallax_factor)
