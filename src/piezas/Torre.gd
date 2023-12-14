extends "res://src/piezas/Base.gd"

var sleeping = true

func validatedMovement(pos1: Vector2, pos2: Vector2, tile: TileMap) -> bool:
	var validated = true
	if pos1.x == pos2.x:
		var _mayor = max(pos1.y, pos2.y)
		var _menor = min(pos1.y, pos2.y)
		for _y in range(_menor + 1, _mayor):
			if tile.get_cell_source_id(0, Vector2i(pos1.x, _y)) != -1:
				validated = false
				break
	elif pos1.y == pos2.y:
		var _mayor = max(pos1.x, pos2.x)
		var _menor = min(pos1.x, pos2.x)
		for _x in range(_menor + 1, _mayor):
			if tile.get_cell_source_id(0, Vector2i(_x, pos1.y)) != -1:
				validated = false
				break
	else: return false
	
	if sleeping and validated:
		sleeping = false
	return validated
