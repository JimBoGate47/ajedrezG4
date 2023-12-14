extends TileMap


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	show_tiles()
	
	
func show_tiles():
	var idx = 0
	for i in range(8):
		for j in range(8):
			set_cell(0, Vector2i(i, j), idx, Vector2i.ZERO)
			idx = 7 if idx == 0 else 0
		idx = 7 if idx == 0 else 0 


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


	
