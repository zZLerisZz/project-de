extends Node

var players = []
var nick: String = "Player"
var can_start = false
@onready var world_scene = load("res://Scenes/world.tscn").instantiate()
@onready var player_scene = preload("res://Scenes/player.tscn")

func _ready() -> void:
	$MainMenuInterface.visible = true
	$GameMenuInterface.visible = false
	$SettingsMenuInterface.visible = false
	$LobbyMenu.visible = false
	
	multiplayer.peer_connected.connect(_on_client_connected)
	multiplayer.peer_disconnected.connect(_on_disconnect_work_with)


func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("quit"):
		if $MainMenuInterface.visible:
			get_tree().quit()
		
		if $GameMenuInterface.visible:
			if $GameMenuInterface/ChooseMenu.visible:
				$GameMenuInterface.visible = false
				$MainMenuInterface.visible = true
			
			if $GameMenuInterface/JoinMenu.visible:
				$GameMenuInterface/JoinMenu.visible = false
				$GameMenuInterface/ChooseMenu.visible = true
		
		if $SettingsMenuInterface.visible:
			$SettingsMenuInterface.visible = false
			$MainMenuInterface.visible = true
			
		if $LobbyMenu.visible:
			_on_lobby_back_button_pressed()


func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _on_game_button_pressed() -> void:
	$MainMenuInterface.visible = false
	
	$GameMenuInterface.visible = true
	$GameMenuInterface/ChooseMenu.visible = true
	$GameMenuInterface/JoinMenu.visible = false

   
func _on_back_to_menu_button_pressed() -> void:
	$MainMenuInterface.visible = true
	$GameMenuInterface.visible = false


func _on_create_game_lobby_button_pressed() -> void:
	$GameMenuInterface/ChooseMenu.visible = false
	var port = find_free_port(1050, 10000)
	$LobbyMenu/MarginContainer/VBoxContainer/PortLabel.text = "Port: " + str(port)
	
	players = []
	can_start = false
	
	$LobbyMenu/MarginContainer/VBoxContainer/JoinerLabel.text = ""
	
	var peer = ENetMultiplayerPeer.new()
	var err = peer.create_server(port, 2)
	if err:
		print_debug("Error in creating server")
		return
	multiplayer.multiplayer_peer = peer
	if multiplayer.is_server():
		print_debug("Server was created")
	
	update_players_nicknames(multiplayer.get_unique_id(), nick)
	_on_client_connected(multiplayer.get_unique_id())
	
	upnp_setup(port)
	
	$LobbyMenu/MarginContainer/VBoxContainer/ReadyButton.text = "Запустить"
	
	$LobbyMenu.visible = true


func _on_client_connected(peer_id) -> void:
	if peer_id != multiplayer.get_unique_id():
		update_players_nicknames.rpc_id(peer_id, multiplayer.get_unique_id(), nick)


func find_free_port(start_port: int, end_port: int) -> int:
	var address: String = "127.0.0.1"
	var tcp_client = StreamPeerTCP.new()
	
	for port in range(start_port, end_port + 1):
		var err = tcp_client.connect_to_host(address, port)
		
		if err == OK:
			tcp_client.disconnect_from_host()
			return port
	
	return -1


func _on_join_game_lobby_button_pressed() -> void:
	$GameMenuInterface/ChooseMenu.visible = false
	
	$GameMenuInterface/JoinMenu.visible = true


func _on_join_button_pressed() -> void:
	$GameMenuInterface.visible = false
	
	var ip_address = $GameMenuInterface/JoinMenu/MarginContainer/VBoxContainer/IPAdressLineEdit.text
	var port = int($GameMenuInterface/JoinMenu/MarginContainer/VBoxContainer/PortLineEdit.text)
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(ip_address, port)

	update_players_nicknames(peer.get_unique_id(), nick)
	if error:
		print_debug("Error in creating server")
		return
	multiplayer.multiplayer_peer = peer
	
	$LobbyMenu/MarginContainer/VBoxContainer/IpLabel.text = "IP: " + ip_address
	$LobbyMenu/MarginContainer/VBoxContainer/PortLabel.text = "Port: " + str(port)
	$LobbyMenu/MarginContainer/VBoxContainer/ReadyButton.text = "Подтвердить готовность"
	
	$LobbyMenu.visible = true

@rpc("any_peer")
func update_players_nicknames(id, nickname):
	players.append({"peer_id": id, "nick": nickname})
	var single_player = player_scene.instantiate()
	print_debug(str(id) + " player create") 
	single_player.name = str(id)
	print_debug("New players " + nickname + " name: " + single_player.name)
	world_scene.add_child(single_player)
	print_debug(nick + " added " + nickname)
	if id != 1:
		$LobbyMenu/MarginContainer/VBoxContainer/JoinerLabel.text = "2." + nickname + " не готов"
	else:
		$LobbyMenu/MarginContainer/VBoxContainer/HostLabel.text = "1." + nickname


func _on_accept_button_pressed() -> void:
	nick = $SettingsMenuInterface/MarginContainer/VBoxContainer/NicknameLineEdit.text
	$SettingsMenuInterface/MarginContainer/VBoxContainer/NicknameLineEdit.text = ""
	$SettingsMenuInterface/MarginContainer/VBoxContainer/NicknameLineEdit.placeholder_text = nick
	print_debug(nick)


func _on_back_button_pressed() -> void:	
	$MainMenuInterface.visible = true
	$SettingsMenuInterface.visible = false


func _on_settings_button_pressed() -> void:
	$MainMenuInterface.visible = false
	$SettingsMenuInterface.visible = true

@rpc("any_peer")
func _on_ready_button_pressed() -> void:
	if not multiplayer.is_server():
		change_readiness()
		change_readiness.rpc_id(1)
		if can_start:
			$LobbyMenu/MarginContainer/VBoxContainer/ReadyButton.text = "Отменить готовность"
		else:
			$LobbyMenu/MarginContainer/VBoxContainer/ReadyButton.text = "Подтвердить готовность"
	else:
		if can_start:
			start_game.rpc_id(players[1].peer_id)
			start_game()

@rpc("any_peer")
func start_game() -> void:
	world_scene.players = players
	get_tree().current_scene.queue_free()
	get_tree().root.add_child(world_scene)
	get_tree().current_scene = world_scene
	get_tree().current_scene.multiplayer.multiplayer_peer = multiplayer.multiplayer_peer

@rpc("any_peer")
func change_readiness() -> void:
	var nick_of_joiner = ""
	can_start = not can_start
	if players[0].peer_id == 1:
		nick_of_joiner = players[1].nick
	else:
		nick_of_joiner = players[0].nick
	if can_start:
		nick_of_joiner = "2." + nick_of_joiner + " готов"
	else:
		nick_of_joiner = "2." + nick_of_joiner + " не готов"
	$LobbyMenu/MarginContainer/VBoxContainer/JoinerLabel.text = nick_of_joiner

func _on_lobby_back_button_pressed() -> void:
	$LobbyMenu.visible = false
	$GameMenuInterface.visible = true
	if multiplayer.is_server():
		$GameMenuInterface/ChooseMenu.visible = true
	else:
		$GameMenuInterface/JoinMenu.visible = true
	_clear_player(multiplayer.get_unique_id())
	multiplayer.multiplayer_peer = null

func _clear_player(name):
	var player = world_scene.get_node_or_null(str(name))
	if player:
		player.queue_free()

func _on_disconnect_work_with(peer_id):
	_clear_player(peer_id)
	if peer_id == 1:
		_on_lobby_back_button_pressed()
	else:
		players = []
		players.append({"peer_id": multiplayer.get_unique_id(), "nick": nick})
		$LobbyMenu/MarginContainer/VBoxContainer/JoinerLabel.text = ""

func upnp_setup(free_port):
	var upnp = UPNP.new()
	
	var discover_result = upnp.discover()
	assert(discover_result == UPNP.UPNP_RESULT_SUCCESS, \
		"UPNP Discover Failed! Error %s" % discover_result)

	assert(upnp.get_gateway() and upnp.get_gateway().is_valid_gateway(), \
		"UPNP Invalid Gateway!")

	var map_result = upnp.add_port_mapping(free_port)
	assert(map_result == UPNP.UPNP_RESULT_SUCCESS, \
		"UPNP Port Mapping Failed! Error %s" % map_result)
	
	print("Success! Join Address: %s" % upnp.query_external_address())
