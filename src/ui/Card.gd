extends Control

signal card_color(id)

var label
var option_button
var colorRect

# Called when the node enters the scene tree for the first time.
func _ready():
	label = $Label
	colorRect = $ColorRect
	option_button = $OptionButton
	option_button.item_selected.connect(_on_item_selected)

func _on_item_selected(id):
	colorRect.color = Color(1,1,1,1) if id==0 else Color(0,0,0,1)
	card_color.emit(id)

func set_player(pname, color_id):
	label.text = pname
	option_button.select(color_id)
	option_button.item_selected.emit(color_id)

func get_player():
	return [label.text, option_button.get_selected_id()]
	
func readonly():
	option_button.disabled = true
