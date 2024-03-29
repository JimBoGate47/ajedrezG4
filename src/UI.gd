extends CanvasLayer

signal create_server(conn_data)
signal join_server(conn_data)

var button1
var button2
var textEdit
var textName

var _connection_data = {port=8000, address='0.0.0.0', max_connections=4, p_name='poser'}

# Called when the node enters the scene tree for the first time.
func _ready():
	button1 = $Button1
	button2 = $Button2
	textEdit = $TextEdit
	textName = $TextEditName
	
	button1.pressed.connect(_on_create_server)
	button2.pressed.connect(_on_join_server)
	textEdit.text_changed.connect(_on_text_changed)
	textName.text_changed.connect(_on_text_name_changed)


func _on_create_server():
	_connection_data.p_name = textName.get_text()
	print("UI: Serving ", _connection_data)
	create_server.emit(_connection_data)

func _on_join_server():
	print("UI: Joinning ", _connection_data)
	_connection_data.p_name = textName.get_text()
	_connection_data.address = textEdit.get_text()
	join_server.emit(_connection_data)

func _on_text_name_changed():
	var text = textName.get_text()
	if text:
		if text.length() >11: text = text.substr(0,11)
		var regx = RegEx.new()
		regx.compile("[a-zA-Z0-9]+")
		#print(regx.search(text).get_string())
		textName.set_text(regx.search(text).get_string())
		textName.set_caret_column(text.length())

func _on_text_changed():
	var text = textEdit.get_text()
	if text:
		var regx = RegEx.new()
		regx.compile("[0-9.]+")
		#print(regx.search(text).get_string())
		textEdit.set_text(regx.search(text).get_string())
		textEdit.set_caret_column(text.length())
