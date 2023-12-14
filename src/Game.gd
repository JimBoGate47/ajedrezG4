extends Node2D

var piezas
var tablero
var ui
var lobby
var players_loaded = 0
const PORT = 8000
const DEFAULT_SERVER_IP = "127.0.0.1"
const MAX_CONNECTIONS = 4
var player_info = {}
var my_info = {name="PPPlayer", color=0}
var server_ncolor = null # Server managed and delivered

func _ready():
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	piezas = $Piezas
	tablero = $Tablero
	ui = $UI
	lobby = $Lobby

	ui.create_server.connect(_on_create_server)
	ui.join_server.connect(_on_join_server)
	piezas.end_game.connect(_on_stopGame)
	lobby.start_game.connect(_on_launch_game)
	lobby.back_menu.connect(_on_back_menu)
	piezas.disable()
	lobby.hide()
	tablero.hide()

func _on_create_server(pname):
	my_info.name = pname
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, MAX_CONNECTIONS)
	#var peer = WebSocketMultiplayerPeer.new()
	#var error = peer.create_server(PORT, "127.0.0.1")
	if error:
		print("ALgo salio mal")
	player_info[1] = my_info
	multiplayer.multiplayer_peer = peer
	print(multiplayer.get_unique_id(), " SERVER running ", pname)
	
	server_ncolor = 0
	ui.hide()
	lobby.enable()
	lobby.add_player(1, my_info)
	lobby.set_my_card(1)

func _on_join_server(pname, ip):
	my_info.name = pname
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(ip, PORT)
	#var peer = WebSocketMultiplayerPeer.new()
	#var server_url = "wss://{0}:{1}".format([ip, PORT])
	#var error = peer.create_client(server_url)
	if error:
		print("CLIENT ALgo salio mal")
	multiplayer.multiplayer_peer = peer
	
	print(multiplayer.get_unique_id(), " CLIENTE connecting ... ")
	
	ui.hide()
	lobby.enable()

@rpc("reliable")
func _remote_launch_game():
	print(multiplayer.get_unique_id(), " REMOTE LAUNCH ")
	lobby._on_start_game()


func _on_launch_game(data):
	print("Receive start game ", data)
	piezas.set_player_data(data[1])
	piezas.draw_pieces()
	piezas.enable()
	tablero.show()
	lobby.hide()
	_remote_launch_game.rpc()

func _on_back_menu():
	print("Receive back menu")
	ui.show()
	lobby.hide()
	player_info.clear()
	multiplayer.multiplayer_peer = null
	
func _on_stopGame(winner):
	print("Ganador ", winner)
	player_info.clear()
	piezas.disable()
	tablero.hide()
	ui.show()

func _process(_delta):
	$Label.text = "FPS: " + str(Engine.get_frames_per_second())

func _on_connected_to_server():
	# TODO lock Lobby UI until server response
	# TODO add SYNC button on Lobby UI to try reconnect ...
	# TODO disable start_game button on client side
	
	print(multiplayer.get_unique_id(), " Connected to server ")
	_register_player.rpc_id(1, my_info)

func _on_connection_failed():
	print("Connection failed")
	multiplayer.multiplayer_peer = null

func _on_player_connected(id):
	print(multiplayer.get_unique_id(), " Peer connected ", id)

func _on_peer_disconnected(id):
	print(multiplayer.get_unique_id(), " Peer disconnected ", id)
	player_info.erase(id)
	if lobby.exist_player(id):
		lobby.remove_player(id)

func _on_server_disconnected():
	multiplayer.multiplayer_peer = null
	print(multiplayer.get_unique_id(), " Server disconnected")
	lobby._on_back_menu()


####################################

@rpc("any_peer", "reliable")
func _register_player(new_player_info):
	var new_player_id = multiplayer.get_remote_sender_id()
	server_ncolor += 1
	new_player_info.color = server_ncolor
	player_info[new_player_id] = new_player_info
	print(multiplayer.get_unique_id(), " SENDER ", multiplayer.get_remote_sender_id(), " ", player_info)
	_register_response.rpc(player_info)
	print_players()

@rpc("reliable")
func _register_response(all_players):
	print(multiplayer.get_unique_id(), " PLAYERS", multiplayer.get_remote_sender_id(), " ",  all_players)
	player_info = all_players
	print_players()
	lobby.set_my_card(multiplayer.get_unique_id())
	
func print_players():
	for _id in player_info.keys():
		if not lobby.exist_player(_id): 
			lobby.add_player(_id, player_info[_id])
	
###################################
