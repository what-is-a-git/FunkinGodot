extends CheckBox

@onready var charter = $"../../../"

func _ready():
	charter.connect("changed_section", Callable(self, "update_value"))
	update_value()

func update_value():
	toggle_mode = charter.song.notes[charter.selected_section].mustHitSection
