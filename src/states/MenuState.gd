extends State

@onready var ui = $/root/Player/UI

func _ready():
	pass

func enter(_msg := {}) -> void:
	ui.show()
	ui.create_server.connect(_onCreateServer)
	ui.join_server.connect(_onJoinServer)

func exit():
	ui.hide()

func _onCreateServer(conn_data):
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(conn_data.port, conn_data.max_connections)
	#var peer = WebSocketMultiplayerPeer.new()
	#var error = peer.create_server(PORT, "127.0.0.1")
	if error:
		print("SERVER algo salio mal")
	multiplayer.multiplayer_peer = peer
	print("UIState:: server created")
	state_machine.transition_to("LobbyState", {name=conn_data.p_name, color=0, server=true})

func _onJoinServer(conn_data):
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(conn_data.address, conn_data.port)
	#var peer = WebSocketMultiplayerPeer.new()
	#var server_url = "wss://{0}:{1}".format([ip, PORT])
	#var error = peer.create_client(server_url)
	if error:
		print("CLIENT ALgo salio mal")
	multiplayer.multiplayer_peer = peer
	print("UIState:: peer ",multiplayer.get_unique_id(), " connecting ... ")
	state_machine.transition_to("LobbyState", {name=conn_data.p_name, color=1, server=false})

