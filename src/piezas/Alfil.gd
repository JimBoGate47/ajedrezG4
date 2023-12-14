extends "res://src/piezas/Base.gd"

func validatedMovement(pos1: Vector2, pos2: Vector2, tile: TileMap) -> bool:
	if abs(pos1.x - pos2.x) == abs(pos1.y - pos2.y):
		var dir = Vector2(1 if pos1.x < pos2.x else -1, 1 if pos1.y < pos2.y else -1)
		for _i in range(1, abs(pos1.x - pos2.x)):
			if tile.get_cell_source_id(0, Vector2i(pos1.x + dir.x * _i, pos1.y + dir.y * _i)) != -1:
				return false
		return true
	return false
