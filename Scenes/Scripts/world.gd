extends Node

@export var players = []

func _ready() -> void:
	multiplayer.peer_disconnected.connect(_on_player_disconnected)

func _on_player_disconnected(peer_id):
	return

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
