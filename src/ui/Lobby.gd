# TODO al escoger el cambio de color de mi card, en mi ventana se tiene que bloquear los otros cards
# tal vez en _broadcastChangeColor.

# TODO los colores en los cards no deben ser repetidos, hace que en GameState no se procesen 
# correctamente el movimiento de las piezas, por ejemplo rey se mueve como reina para el otro player.


extends CanvasLayer


signal start_game(player_data)
signal back_menu

var nplayers = 0
var card = preload("res://Card.tscn")
var player_cards = {}
var buttonStart
var buttonBack
var my_card = null
var my_info = {name="probando", color=1}	# FIXME perhaps remove the variable
var constantes = load("res://src/constantes.gd")
var players_db

func _ready():
	buttonStart = $ButtonStart
	buttonBack = $ButtonBack
	buttonStart.pressed.connect(_on_start_game)
	buttonBack.pressed.connect(_on_back_menu)
	players_db = PlayersDB.new()
	#JUST for testing
	#add_player("Himbo", 1)
	#add_player("Himboaa", 0)

func enable():
	show()

func add_player(id, p_info, readonly=false):
	var nu = card.instantiate()
	add_child(nu)
	nu.position = Vector2i(100, 200 + nu.size.y * nplayers)
	nu.set_player(p_info.name, p_info.color)
	if readonly: nu.readonly()
	
	player_cards[id] = nu
	nplayers += 1

func set_my_card(id):
	# FIXME no se que se tiene que reparar.
	#if players_db.isEmpty(): return
	my_card = player_cards[id]
	my_card.card_color.connect(_on_card_change_color)

func exist_player(id):
	return id in player_cards

func _reorganize_cards():
	var i = 0
	for _c in player_cards.values():
		_c.position = Vector2i(100, 200 + _c.size.y * i)
		i += 1

func _on_card_change_color(color_id):
	print("LOBBY::CARD:: change color ", color_id)
	var _id = multiplayer.get_unique_id()
	players_db.updateColor(_id, color_id)
	_broadcastChangeColor.rpc(_id, color_id)

@rpc("any_peer", "reliable")
func _broadcastChangeColor(_id, _color_id):
	var _card = player_cards[_id]
	_card._on_item_selected(_color_id)
	#for _c in player_cards.values():
	#	if _c != _card:
	#		_c._on_item_selected(constantes.PColor.WHITE if _color_id != constantes.PColor.WHITE else constantes.PColor.BLACK)

@rpc("reliable")
func _on_start_game():
	print("Signal Starting game ", my_card.get_player())
	_on_start_game.rpc()
	emit_signal("start_game", my_card.get_player())

func _on_back_menu():
	multiplayer.multiplayer_peer = null
	back_menu.emit()


################################
func _register_server(_info):
	my_info = _info
	var _id = multiplayer.get_unique_id()
	players_db.addPlayer(_id, _info)
	add_player(_id, players_db.getPlayer(_id))
	set_my_card(multiplayer.get_unique_id())

func clear_players():
	for _c in player_cards.values():
		remove_child(_c)
	player_cards.clear()
	players_db.clearAll()
	nplayers = 0

@rpc("any_peer", "reliable")
func remove_player(id):
	if players_db.isEmpty(): return
	remove_child(player_cards[id])
	player_cards.erase(id)
	nplayers -= 1
	_reorganize_cards()

@rpc("any_peer", "reliable")
func _register_player(new_player_info):
	var _new_id = multiplayer.get_remote_sender_id()
	players_db.addPlayer(_new_id, new_player_info)
	print("LOBBY::Register ", multiplayer.get_unique_id(), " SENDER ", multiplayer.get_remote_sender_id(), " ", players_db.allPlayers())
	_register_response.rpc(players_db.allPlayers())
	print_players()

@rpc("reliable")
func _register_response(all_players):
	print("LOBBY::Response ", multiplayer.get_unique_id(), " PLAYERS", multiplayer.get_remote_sender_id(), " ",  all_players)
	players_db._players = all_players
	print_players()
	
func print_players():
	for _id in players_db.allPlayers().keys():
		if not exist_player(_id): 
			add_player(_id, players_db.getPlayer(_id))
	set_my_card(multiplayer.get_unique_id())

