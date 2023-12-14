extends "res://src/piezas/Base.gd"

func validatedMovement(pos1: Vector2, pos2: Vector2, _tile: TileMap) -> bool:
	if abs(pos1.y - pos2.y) == 2 and  abs(pos1.x - pos2.x) == 1:
		return true
	return abs(pos1.x - pos2.x) == 2 and  abs(pos1.y - pos2.y) == 1
