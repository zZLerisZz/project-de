extends Node

@export var players = []

func _ready() -> void:
	return

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
