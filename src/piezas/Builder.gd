
var constantes = load("res://src/constantes.gd")
const _peon = preload("res://src/piezas/Peon.gd")
var _torre = load("res://src/piezas/Torre.gd")
var _caballo = load("res://src/piezas/Caballo.gd")
var _alfil = load("res://src/piezas/Alfil.gd")
var _reina = load("res://src/piezas/Reina.gd")
var _rey = load("res://src/piezas/Rey.gd")

var _all_pieces: Dictionary = {}

var _extra_movements = []
var _on_doble_step_notified = [] # Array of peones that have capture on step enabled

func reset():
	_all_pieces.clear()
	_extra_movements.clear()

func set_messenger():
	pass

func build(xy: Vector2, value, tilemap: TileMap):
	tilemap.set_cell(0, xy, value, Vector2i.ZERO)
	match(value):
		constantes.WPieces.PEON, constantes.BPieces.PEON:
			_all_pieces[_xy2key(xy)] = _peon.new()
			_all_pieces[_xy2key(xy)].doble_step.connect(_on_doble_step)
		constantes.WPieces.TORRE, constantes.BPieces.TORRE:
			_all_pieces[_xy2key(xy)] = _torre.new()
		constantes.WPieces.CABALLO, constantes.BPieces.CABALLO:
			_all_pieces[_xy2key(xy)] = _caballo.new()
		constantes.WPieces.ALFIL, constantes.BPieces.ALFIL:
			_all_pieces[_xy2key(xy)] = _alfil.new()
		constantes.WPieces.REINA, constantes.BPieces.REINA:
			_all_pieces[_xy2key(xy)] = _reina.new()
		constantes.WPieces.REY, constantes.BPieces.REY:
			_all_pieces[_xy2key(xy)] = _rey.new(self)
		_:
			return -1

func _xy2key(xy:Vector2) -> int:
	return int(xy.y * 8 + xy.x)

func get_piece(pos: Vector2):
	return _all_pieces[_xy2key(pos)]

func updatePosition(pos1: Vector2, pos2: Vector2, obj2_id) -> Array:
	if obj2_id != -1:
		if obj2_id == constantes.WPieces.REY or obj2_id == constantes.BPieces.REY:
			_all_pieces[_xy2key(pos2)].harakiri()
		_all_pieces.erase(_xy2key(pos2))

	if _all_pieces[_xy2key(pos1)] is _peon and (pos2.y == 0 or pos2.y == 7):
		_all_pieces[_xy2key(pos1)].reinaDeLosLagartos(pos2)

	if _on_doble_step_notified.size() != 0:
		for _notif in _on_doble_step_notified.duplicate():
			_notif[0] -= 1
			if _notif[0] == 0:
				_notif[1].set_capture_on_stepX(null)
				_on_doble_step_notified.erase(_notif)
				print("Disabling capture on step ", _notif)
		print("ARRAY: ", _on_doble_step_notified)
	
	var _piece = _all_pieces[_xy2key(pos1)]
	_all_pieces.erase(_xy2key(pos1))
	_all_pieces[_xy2key(pos2)] = _piece

	if _extra_movements.size() != 0:
		var _p1 = _all_pieces[_xy2key(_extra_movements[0][0])]
		_all_pieces.erase(_xy2key(_extra_movements[0][0]))
		_all_pieces[_xy2key(_extra_movements[0][1])] = _p1
		var _arr = _extra_movements + [[pos1, pos2]]
		_extra_movements.clear()
		return _arr
	return [[pos1, pos2]]

func _on_doble_step(pos, tile_id, tile_left, tile_right):
	print("_on_doble_step: ", pos," ", tile_id," ", tile_left," ", tile_right)
	if tile_left != -1 and tile_id != tile_left:
		var _peon_left = _all_pieces[_xy2key(Vector2(pos.x-1, pos.y))]
		_peon_left.set_capture_on_stepX(pos.x)
		_on_doble_step_notified.append([2, _peon_left])

	if tile_right != -1 and tile_id != tile_right:
		var _peon_right = _all_pieces[_xy2key(Vector2(pos.x+1, pos.y))]
		_peon_right.set_capture_on_stepX(pos.x)
		_on_doble_step_notified.append([2, _peon_right])

