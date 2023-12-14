extends Control

signal card_color(id)

var label
var optionButton
var colorRect
var playerColor = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	label = $Label
	colorRect = $ColorRect
	optionButton = $OptionButton
	optionButton.item_selected.connect(_on_item_selected)

func _on_item_selected(id):
	colorRect.color = Color(1,1,1,1) if id==0 else Color(0,0,0,1)
	card_color.emit(id)

func select_color(color_id):
	optionButton.select(color_id)
	optionButton.item_selected.emit(color_id)
	
func set_player(pname, color_id):
	label.text = pname
	select_color(color_id)

func get_player():
	return [label.text, optionButton.get_selected_id()]
	
func readonly():
	optionButton.disabled = true
