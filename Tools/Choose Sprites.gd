extends Button

@onready var file_dialog = $"../../FileDialog"

func popup_shit():
	file_dialog.popup_centered()
