extends Node

# warnings-disable

var debug_printing: bool = false

func init() -> void:
	pass

func _on_ready(user: Dictionary) -> void:
	print("Discord RPC Ready")
	print("Client username: ", user["username"])
	
	update_presence("Starting up the game.")

func _on_error(error: int) -> void:
	print("RPC Connection ERROR: ", error)

func update_presence(details: String, state: String = "",
			small_image_key: String = "", small_image_text: String = "",
			large_image_key: String = "logo", large_image_text: String = "Leather Engine",
			start_time: int = Time.get_unix_time_from_system(), end_time: int = 0):
	if debug_printing:
		print("----------")
		print("Updated Presence Debug:")
		
		print("Details: " + details)
		
		if state != "":
			print("State: " + state)
		
		if small_image_key != "":
			print("Small Key: " + small_image_key)
			print("Small Text: " + small_image_text)
		
		if large_image_key != "logo":
			print("Large Key: " + large_image_key)
			print("Large Text: " + large_image_text)
