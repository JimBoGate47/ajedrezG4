extends "res://src/piezas/Base.gd"

signal king_dead

var sleeping = true
var gameBuilder

func _init(builder):
	gameBuilder = builder
	
func validatedMovement(pos1: Vector2, pos2: Vector2, tile: TileMap) -> bool:
	var validated  = true
	if sleeping and abs(pos1.x - pos2.x) == 2 and pos1.y == pos2.y:
		# Enrroque izquierdo
		if pos1.x > pos2.x and tile.get_cell_source_id(0, Vector2i(0, pos1.y)) != -1 and \
			gameBuilder.get_piece(Vector2(0, pos1.y)).sleeping:
			for _i in range(1, pos1.x):
				if tile.get_cell_source_id(0, Vector2i(_i, pos1.y)) != -1:
					validated = false
					break
			gameBuilder._extra_movements.append([Vector2(0, pos1.y), Vector2(pos1.x - 1, pos1.y)])
		# Enrroque derecho
		elif tile.get_cell_source_id(0, Vector2i(7, pos1.y)) != -1 and gameBuilder.get_piece(Vector2(7, pos1.y)).sleeping:
			for _i in range(pos1.x + 1, 7):
				if tile.get_cell_source_id(0, Vector2i(_i, pos1.y)) != -1:
					validated = false
					break
			gameBuilder._extra_movements.append([Vector2(7, pos1.y), Vector2(pos1.x + 1, pos1.y)])
		else: validated = false
	elif abs(pos1.x - pos2.x) > 1 or abs(pos1.y - pos2.y) > 1: validated = false
	
	if sleeping and validated:
		sleeping = false
	return validated

func harakiri():
	print("Harakiri in progress...")
	king_dead.emit()
