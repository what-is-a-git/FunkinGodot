class_name SongAuthor extends Resource


@export var name: StringName = &'Kawai Sprite'
@export var role: StringName = &'Composer'
@export var icon: Icon = null


func _to_string() -> String:
	return 'SongAuthor(name: %s, role: %s, icon: %s)' % [name, role, icon]
