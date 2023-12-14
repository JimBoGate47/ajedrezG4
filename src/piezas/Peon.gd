extends "res://src/piezas/Base.gd"

signal coronacion
signal doble_step

var special_start = true
var ydir: int = 1
var capture_on_stepX = null

func set_ydir(y_dir):
	self.ydir = y_dir

func validatedMovement(pos1, pos2, tile_map):
	var validated = false
	if special_start and pos1.x == pos2.x and (pos1.y - pos2.y) == 2 * ydir and tile_map.get_cell_source_id(0, Vector2i(pos1.x, pos1.y - ydir)) == -1 and \
	tile_map.get_cell_source_id(0, pos2) == -1:
		validated = true
		doble_step.emit(pos2, tile_map.get_cell_source_id(0, pos1), 
										tile_map.get_cell_source_id(0, Vector2i(pos2.x - 1, pos2.y)),
										tile_map.get_cell_source_id(0, Vector2i(pos2.x + 1, pos2.y)))
	elif (pos1.y - pos2.y) == ydir:
		if pos1.x == pos2.x:
			validated = tile_map.get_cell_source_id(0, pos2) == -1
		elif abs(pos1.x - pos2.x) == 1:
			if capture_on_stepX != null:
				validated = capture_on_stepX == pos2.x
				tile_map.set_cell(0, Vector2i(capture_on_stepX, pos1.y), -1)
			else: validated = tile_map.get_cell_source_id(0, pos2) != -1

	if special_start and validated:
		special_start = false
	return validated

func set_capture_on_stepX(value):
	print("Enabled capture on step X= ", value)
	capture_on_stepX = value

func reinaDeLosLagartos(pos: Vector2):
	print("Soy la Reina de los lagartos! ", pos)
	coronacion.emit(pos)
