extends Node

func _ready() -> void:
	$MainMenuInterface.visible = true
	$GameMenuInterface.visible = false
	$SettingsMenuInterface.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("quit"):
		if $MainMenuInterface.visible:
			get_tree().quit()
		
		if $GameMenuInterface.visible:
			if $GameMenuInterface/ChooseMenu.visible:
				$GameMenuInterface.visible = false
				$MainMenuInterface.visible = true
			
			if $GameMenuInterface/JoinCreateMenu.visible:
				$GameMenuInterface/JoinCreateMenu.visible = false
				$GameMenuInterface/ChooseMenu.visible = true


func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _on_game_button_pressed() -> void:
	$MainMenuInterface.visible = false
	
	$GameMenuInterface.visible = true
	$GameMenuInterface/ChooseMenu.visible = true
	$GameMenuInterface/JoinCreateMenu.visible = false


func _on_back_to_menu_button_pressed() -> void:
	$MainMenuInterface.visible = true
	$GameMenuInterface.visible = false


func _on_create_game_lobby_button_pressed() -> void:
	$GameMenuInterface/ChooseMenu.visible = false
	
	$GameMenuInterface/JoinCreateMenu.visible = true
	$GameMenuInterface/JoinCreateMenu/CreateMenu.visible = true
	$GameMenuInterface/JoinCreateMenu/JoinMenu.visible = false


func _on_create_server_button_pressed() -> void:
	var world_scene = load("res://Scenes/world.tscn").instantiate()
	world_scene.ip_address = $GameMenuInterface/JoinCreateMenu/CreateMenu/MarginContainer/VBoxContainer/IPAdressLineEdit.text
	get_tree().current_scene.queue_free()
	get_tree().root.add_child(world_scene)
	get_tree().current_scene = world_scene


func _on_join_game_lobby_button_pressed() -> void:
	$GameMenuInterface/ChooseMenu.visible = false
	
	$GameMenuInterface/JoinCreateMenu.visible = true
	$GameMenuInterface/JoinCreateMenu/CreateMenu.visible = false
	$GameMenuInterface/JoinCreateMenu/JoinMenu.visible = true
