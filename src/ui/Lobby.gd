extends CanvasLayer


signal start_game(player_data)
signal back_menu

var nplayers = 0
var card = preload("res://Card.tscn")
var player_cards = {}
var buttonStart
var buttonBack
var my_card = null
var constantes = load("res://src/constantes.gd")

func _ready():
	buttonStart = $ButtonStart
	buttonBack = $ButtonBack
	buttonStart.pressed.connect(_on_start_game)
	buttonBack.pressed.connect(_on_back_menu)
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
	# FIXME
	my_card = player_cards[id]
	#my_card.card_color.connect(_on_card_change_color)

func exist_player(id):
	return id in player_cards

func remove_player(id):
	remove_child(player_cards[id])
	player_cards.erase(id)
	nplayers -= 1
	_reorganize_cards()

func clear_players():
	for _c in player_cards.values():
		remove_child(_c)
	player_cards.clear()
	nplayers = 0
	
	
	
func _reorganize_cards():
	var i = 0
	for _c in player_cards.values():
		_c.position = Vector2i(100, 200 + _c.size.y * i)
		i += 1

func _on_card_change_color(color_id, obj):
	# FIXME change color must be sent to any peer
	for _card in player_cards:
		if _card != obj:
			_card.select_color(constantes.PColor.WHITE if color_id != constantes.PColor.WHITE else constantes.PColor.BLACK)

func _on_start_game():
	print("Signal Starting game ", my_card.get_player())
	emit_signal("start_game", my_card.get_player())

func _on_back_menu():
	# Clear all player cards
	print("Signal Back to menu")
	clear_players()
	back_menu.emit()


