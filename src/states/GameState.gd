extends State

@onready var piezas = $/root/Player/Piezas
@onready var tablero = $/root/Player/Tablero

func enter(_msg := {}) -> void:
	print("Piezas ", _msg)
	var data = _msg["card"]
	piezas.set_player_data(data[1])
	piezas.draw_pieces()
	piezas.enable()
	tablero.show()
	piezas.end_game.connect(_on_end_game)

func exit() -> void:
	piezas.disable()
	tablero.hide()

func _on_end_game(winner):
	print("Ganador ", winner)
	state_machine.transition_to("MenuState")
