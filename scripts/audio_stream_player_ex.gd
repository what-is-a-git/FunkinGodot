## An extension of AudioStreamPlayer that allows
## for manual overriding over stream looping.
##
## Supports switching the stream at runtime and
## keeping the override as well, for an optimal
## user experience.
class_name AudioStreamPlayerEX extends AudioStreamPlayer


## Simple variable to define whether or not
## the looping flag should be overriden, and if so,
## for what value.
@export_enum('Stream Default', 'Off', 'On') var looping: int = 0:
	set(value):
		looping = value
		
		if is_instance_valid(stream):
			stream.loop = looping == 2


func _set(property: StringName, value: Variant) -> bool:
	if property == 'stream' and is_instance_valid(value):
		value.loop = looping == 2
	
	return false
