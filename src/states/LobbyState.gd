extends State

@onready var lobby = $/root/Player/Lobby

func _ready():
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	
func enter(_msg := {}) -> void:
	lobby.start_game.connect(_on_launch_game)
	lobby.back_menu.connect(_on_back_menu)
	lobby.enable()
	#lobby.add_player(1, _msg)
	#lobby.set_my_card(1)
	lobby.my_info = _msg
	#lobby._register_player.rpc_id(1, lobby.my_info)
	if _msg.server:
		lobby._register_server(_msg)
	else:
		lobby._register_player.rpc_id(1, _msg)

func exit() -> void:
	lobby.clear_players()
	lobby.hide()

func _on_launch_game(data):
	#print("Receive start game ", data)
	#piezas.set_player_data(data[1])
	#piezas.draw_pieces()
	#piezas.enable()
	#tablero.show()
	state_machine.transition_to("GameState", {card=data})
	
func _on_back_menu():
	print("Regresando ")
	state_machine.transition_to("MenuState")



# connection callbacks

func _on_connected_to_server():
	# TODO lock Lobby UI until server response
	# TODO add SYNC button on Lobby UI to try reconnect ...
	# TODO disable start_game button on client side
	
	print("LOBBYState:: ", multiplayer.get_unique_id(), " Connected to server ")
	lobby._register_player.rpc_id(1, lobby.my_info)

func _on_connection_failed():
	print("LOBBYState:: Connection failed")
	multiplayer.multiplayer_peer = null

func _on_player_connected(id):
	print("LOBBYState:: ", multiplayer.get_unique_id(), " Peer connected ", id)

func _on_peer_disconnected(id):
	print("LOBBYState:: ", multiplayer.get_unique_id(), " Peer disconnected ", id)
	lobby.players_db.removePlayer(id)
	if lobby.exist_player(id):
		lobby.remove_player(id)

func _on_server_disconnected():
	multiplayer.multiplayer_peer = null
	lobby.clear_players()
	lobby._on_back_menu()
	print("LOBBYState:: ", multiplayer.get_unique_id(), " Server disconnected")
