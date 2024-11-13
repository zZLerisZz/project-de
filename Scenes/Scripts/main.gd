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
	var world_scene = load("res://Scenes/world.tscn").instantiate()
	world_scene.ip_address = "1111"
	#get_tree().change_scene_to_file("res://Scenes/world.tscn")
	get_tree().current_scene.queue_free()
	get_tree().root.add_child(world_scene)
	get_tree().current_scene = world_scene

func _on_create_game_lobby_button_pressed() -> void:
	$GameMenuInterface.visible = false
	$JoinCreateMenu.visible = true
