extends TileMap

signal end_game

@export
var playerColor:int = PlayerColor.WHITE

enum PlayerColor{WHITE, BLACK}
enum BlackPieces{TORRE=1, CABALLO=2, ALFIL=3, REINA=4, REY=5, PEON=6}
enum WhitePieces{TORRE=8, CABALLO=9, ALFIL=10, REINA=11, REY=12, PEON=13}

const speed:int = 50

var highlighted = null
var last_highlighted = null
#var _texture = preload("res://assets/piezas301x86.png")
var Builder = load("res://src/piezas/Builder.gd")
var builder = Builder.new()
var playing = false
var coronando = false
var player_in_turn = PlayerColor.WHITE
var upgrade_piece: Vector2
var corona
var popup
var messages

func _ready():
	corona = $Corona
	popup = $PopupMenu
	corona.disable()
	corona.new_corona.connect(_remote_on_new_corona)
	popup.id_pressed.connect(_on_popup_id_pressed)
	popup.popup_hide.connect(_on_popup_hide)
	
	# just for testing:
	#draw_pieces()
	#enable()

func set_player_data(id):
	playerColor = id
	
func enable():
	playing = true
	show()

func disable():
	playing = false
	hide()
	
func _reset():
	clear()
	builder.reset()
	corona.disable()
	highlighted = null
	last_highlighted = null
	coronando = false

func draw_pieces():
	_reset()
	var oponent = WhitePieces if playerColor != PlayerColor.WHITE else BlackPieces
	var player = WhitePieces if playerColor == PlayerColor.WHITE else BlackPieces
	
	for i in range(8):
		builder.build(Vector2(i, 1), oponent.PEON, self)
		builder.build(Vector2(i, 6), player.PEON, self)
		builder.get_piece(Vector2(i, 1)).set_ydir(-1)
		builder.get_piece(Vector2(i, 1)).coronacion.connect(_on_coronacion)
		builder.get_piece(Vector2(i, 6)).coronacion.connect(_on_coronacion)
	
	builder.build(Vector2(0, 0), oponent.TORRE, self)
	builder.build(Vector2(7, 0), oponent.TORRE, self)
	builder.build(Vector2(1, 0), oponent.CABALLO, self)
	builder.build(Vector2(6, 0), oponent.CABALLO, self)
	builder.build(Vector2(2, 0), oponent.ALFIL, self)
	builder.build(Vector2(5, 0), oponent.ALFIL, self)
	
	builder.build(Vector2(0, 7), player.TORRE, self)
	builder.build(Vector2(7, 7), player.TORRE, self)
	builder.build(Vector2(1, 7), player.CABALLO, self)
	builder.build(Vector2(6, 7), player.CABALLO, self)
	builder.build(Vector2(2, 7), player.ALFIL, self)
	builder.build(Vector2(5, 7), player.ALFIL, self)
	
	if playerColor == PlayerColor.WHITE:
		builder.build(Vector2(3, 0), oponent.REINA, self)
		builder.build(Vector2(4, 0), oponent.REY, self)
		builder.build(Vector2(3, 7), player.REINA, self)
		builder.build(Vector2(4, 7), player.REY, self)
		builder.get_piece(Vector2(4, 0)).king_dead.connect(_on_winner.bind(playerColor))
		builder.get_piece(Vector2(4, 7)).king_dead.connect(_on_winner.bind(
				PlayerColor.WHITE if playerColor == PlayerColor.BLACK else PlayerColor.WHITE))
	else:
		builder.build(Vector2(3, 0), oponent.REY, self)
		builder.build(Vector2(4, 0), oponent.REINA, self)
		builder.build(Vector2(3, 7), player.REY, self)
		builder.build(Vector2(4, 7), player.REINA, self)
		builder.get_piece(Vector2(3, 0)).king_dead.connect(_on_winner.bind(playerColor))
		builder.get_piece(Vector2(3, 7)).king_dead.connect(_on_winner.bind( 
				PlayerColor.WHITE if playerColor == PlayerColor.BLACK else PlayerColor.WHITE))
	#var tmp = builder._all_pieces.keys()
	#tmp.sort()
	#print(tmp)

func _input(event):
	if event.is_action_released("ui_cancel"):
		popup_enable()

	if coronando: return
	
	if not playing: return

	if event is InputEventMouseButton and event.button_index == 1 and event.is_pressed():
		var pos = local_to_map(get_local_mouse_position())
		if pos.x < 0 or pos.x > 7 or pos.y < 0 or pos.y > 7: return
		#if not is_player_in_turn(pos): return    # TODO enable to filter player 
		highlight(pos)

func is_player_in_turn(pos):
	# If the player is in turn continue the play, used in conjunction of change_player_turn
	if playerColor == player_in_turn:
		if get_cell_source_id(0, pos) < 0 or highlighted != null: return true
		if player_in_turn == PlayerColor.WHITE:
			return get_cell_source_id(0, pos) in WhitePieces.values()
		elif player_in_turn == PlayerColor.BLACK:
			return get_cell_source_id(0, pos) in BlackPieces.values()
	return false

func change_player_in_turn():
	player_in_turn = PlayerColor.BLACK if player_in_turn == PlayerColor.WHITE else PlayerColor.WHITE

func highlight(pos: Vector2):
	if highlighted == null:
		if get_cell_source_id(0, pos) != -1:
			highlighted =  pos
			last_highlighted = null
			queue_redraw()
	else:
		if highlighted != pos:
			if WhitePieces.values().has(get_cell_source_id(0, highlighted)):
				if WhitePieces.values().has(get_cell_source_id(0, pos)):
					highlighted =  pos
					queue_redraw()
					return
			else:
				if BlackPieces.values().has(get_cell_source_id(0, pos)):
					highlighted =  pos
					queue_redraw()
					return
			changePosition(pos)
			# TODO si es posible ejecutar solo cuando esta validado
			_remote_changePosition.rpc(highlighted, pos)
			_remote_change_turn.rpc() # TODO ejecutar solo cuando esta validado

@rpc("any_peer", "call_local", "reliable")
func _remote_change_turn():
	"""Change player turn on each piece movement"""
	change_player_in_turn()
	
@rpc("any_peer", "reliable")
func _remote_changePosition(pos0, pos1):
	highlighted = -pos0 + 7 * Vector2.ONE
	pos1 = - pos1 + 7* Vector2.ONE
	#print("ADJUSTED ", highlighted, " ", pos1)
	changePosition(pos1)
	
func changePosition(pos: Vector2):
	var _piece = builder.get_piece(highlighted)
	if not _piece.validatedMovement(highlighted, pos, self): return
	
	var _arr_positions = builder.updatePosition(highlighted, pos, get_cell_source_id(0, pos))
	
	_animate_moves(_arr_positions)
	#_instantChange(_tile, p1p2[1], specialSprite)

func _animate_moves(arr_pos: Array):
	playing = false
	for p1p2 in arr_pos:
		var _tile = get_cell_source_id(0, p1p2[0])
		set_cell(0, p1p2[0], -1)
		set_cell(0, p1p2[1], -1)
		
		var specialSprite = SpecialSprite.new(tile_set.get_source(_tile).texture)
		add_child(specialSprite)
		specialSprite.load_region(tile_set.get_source(_tile).get_tile_texture_region(Vector2i.ZERO))
		specialSprite.load_position(map_to_local(p1p2[0]))
		var tween = get_tree().create_tween()
		tween.tween_property(specialSprite.get_sprite(), "position", map_to_local(p1p2[1]), 0.3)
		tween.tween_callback(_instantChange.bind(_tile, p1p2[1], specialSprite))
	
func _instantChange(tile0, pos, sSprite):
	remove_child(sSprite)
	sSprite.queue_free()
	
	set_cell(0, pos, tile0, Vector2i.ZERO)
	highlighted = null
	last_highlighted = pos
	queue_redraw()
	playing = true

func _draw():
	if highlighted != null:
		var rect = Rect2(Vector2i(highlighted) * tile_set.tile_size, tile_set.tile_size)
		draw_rect(rect, Color(0,1,1,0.5))
	elif last_highlighted != null:
		var rect = Rect2(Vector2i(last_highlighted) * tile_set.tile_size, tile_set.tile_size)
		draw_rect(rect, Color(0.7,0.6,1,1))

func _on_winner(winner):
	print("Finish him")
	playing = false
	end_game.emit(winner)

func start_coronacion():
	if playerColor == player_in_turn:
		corona.enable(playerColor)
	
func stop_coronacion():
	corona.disable()
	
func _on_coronacion(pos):
	print("On coronacion ", pos)
	coronando = true
	upgrade_piece = pos
	start_coronacion()

func _remote_on_new_corona(value):
	#_on_new_corona(value)
	_on_new_corona.rpc(value)

@rpc("any_peer", "call_local", "reliable")
func _on_new_corona(value):
	print("Nueva corona ", value)
	builder.build(upgrade_piece, value, self)
	coronando = false
	stop_coronacion()


func popup_enable():
	popup.show()
	if playing: playing = false

func _on_popup_id_pressed(id):
	print("ID PRESSED ", id)
	if id == 0:
		print("END_GAME ", id)
		main_menu.rpc()

func _on_popup_hide():
	if not playing: playing = true

@rpc("any_peer", "call_local", "reliable")
func main_menu():
	end_game.emit("rayos")
