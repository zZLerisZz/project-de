extends Node

@export var ip_address: String

func _ready() -> void:
	print_debug(ip_address)

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
