extends Node

@export var players = []

func _ready() -> void:
	$ExitMenu.visible = false
	$AcceptMenu.visible = false
	
	multiplayer.peer_disconnected.connect(_on_player_disconnected)

func _on_player_disconnected(peer_id):
	_on_accept_button_pressed()

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("quit"):
		$ExitMenu.visible = not $ExitMenu.visible
		if $ExitMenu.visible:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		


func _on_return_to_game_button_pressed() -> void:
	$ExitMenu.visible = not $ExitMenu.visible
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _on_exit_form_game_button_pressed() -> void:
	$ExitMenu.visible = false
	$AcceptMenu.visible = true


func _on_accept_button_pressed() -> void:
	#ЗДЕСЬ ДОБАВИТЬ ПЕРЕКИДЫВАНИЕ НА ЭКРАН РЕЗУЛЬТАТА ИГРЫ!!!
	multiplayer.multiplayer_peer = null
	var main_scene = load("res://Scenes/main.tscn").instantiate()
	get_tree().current_scene.queue_free()
	get_tree().root.add_child(main_scene)
	get_tree().current_scene = main_scene


func _on_decline_button_pressed() -> void:
	$AcceptMenu.visible = false
