extends Node

func _ready() -> void:
	$GameMenuInterface.visible = false
	$SettingsMenuInterface.visible = false
	$JoinCreateMenu.visible = false


func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _on_game_button_pressed() -> void:
	$MainMenuInterface.visible = false
	$GameMenuInterface.visible = true


func _on_back_to_menu_button_pressed() -> void:
	$MainMenuInterface.visible = true
	$GameMenuInterface.visible = false


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/world.tscn")


func _on_create_game_lobby_button_pressed() -> void:
	$GameMenuInterface.visible = false
	$JoinCreateMenu.visible = true
