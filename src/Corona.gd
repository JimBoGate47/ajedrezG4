extends TileMap

signal new_corona(_id:int)

@export
var playerColor:int = PlayerColor.WHITE

enum PlayerColor{WHITE, BLACK}
enum BlackPieces{TORRE=1, CABALLO=2, ALFIL=3, REINA=4, REY=5, PEON=6}
enum WhitePieces{TORRE=8, CABALLO=9, ALFIL=10, REINA=11, REY=12, PEON=13}

var playing = false
var offset = Vector2i(8, 2)

func _ready():
	enable(playerColor)

func enable(player_color):
	playing = true
	self.playerColor = player_color
	var player = WhitePieces if playerColor == PlayerColor.WHITE else BlackPieces
	draw_pieces(player)
	show()

func disable():
	playing = false
	hide()

func draw_pieces(player):
	set_cell(0, Vector2i(offset.x, offset.y + 0), player.REINA, Vector2i.ZERO)
	set_cell(0, Vector2i(offset.x, offset.y + 1), player.ALFIL, Vector2i.ZERO)
	set_cell(0, Vector2i(offset.x, offset.y + 2), player.CABALLO, Vector2i.ZERO)
	set_cell(0, Vector2i(offset.x, offset.y + 3), player.TORRE, Vector2i.ZERO)
	
func set_offset(_offset: Vector2):
	self.offset = _offset
	
func _input(event):
	if not playing: return
	if event is InputEventMouseButton and event.button_index == 1 and event.is_pressed():
		var pos = local_to_map(get_local_mouse_position())
		if get_cell_source_id(0, pos) == -1: return
		new_corona.emit(get_cell_source_id(0, pos))

func _draw():
	#map_to_local(offset)
	var rect = Rect2(tile_set.tile_size * offset, Vector2i(tile_set.tile_size.x, 4 * tile_set.tile_size.y))
	draw_rect(rect, Color(1,1,1,1))
	draw_rect(rect, Color(0,0,0,1), false, 3)
