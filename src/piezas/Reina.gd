extends "res://src/piezas/Base.gd"

func validatedMovement(pos1: Vector2, pos2: Vector2, tile: TileMap) -> bool:
	var validated = true
	if abs(pos1.x - pos2.x) == abs(pos1.y - pos2.y):
		var dir = Vector2(1 if pos1.x < pos2.x else -1, 1 if pos1.y < pos2.y else -1)
		for _i in range(1, abs(pos1.x - pos2.x)):
			if tile.get_cell_source_id(0, Vector2i(pos1.x + dir.x * _i, pos1.y + dir.y * _i)) != -1:
				validated = false
				break
	elif pos1.x == pos2.x:
		var _s = abs(pos1.y - pos2.y)
		var _yo = min(pos1.y, pos2.y)
		for _i in range(1, _s):
			if tile.get_cell_source_id(0, Vector2i(pos1.x, _yo + _i)) != -1:
				validated = false
				break
	elif pos1.y == pos2.y:
		var _s = abs(pos1.x - pos2.x)
		var _xo = min(pos1.x, pos2.x)
		for _i in range(1, _s):
			if tile.get_cell_source_id(0, Vector2i(_xo  + _i, pos1.y)) != -1:
				validated = false
				break
	else: return false
	return validated
