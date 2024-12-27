extends NumberOption


@export var bus: StringName = &'Master'


func _ready() -> void:
	var buses: Dictionary = Config.get_value('sound', 'buses')
	value = buses[bus]


func set_value(value: Variant) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus), 
			linear_to_db(value / 100.0))
	
	var buses: Dictionary = Config.get_value('sound', 'buses')
	buses[bus] = value
	Config.set_value('sound', 'buses', buses)
