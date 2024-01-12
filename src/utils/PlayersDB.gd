class_name PlayersDB
extends RefCounted

var _players = {} # Elements should de dictionary with format: {name:str="jjj", color:int=0}

func addPlayer(user_id, user: Dictionary):
	if not _players.has(user_id):
		_players[user_id] = user
	
func removePlayer(user_id):
	if _players.has(user_id):
		_players.erase(user_id)

func updateColor(user_id, color_id):
	_players[user_id].color = color_id

func getPlayer(id):
	return _players[id]
	
func allPlayers():
	return _players
	
func clearAll():
	_players.clear()

func isEmpty():
	return _players.is_empty()
	
func printPlayers():
	print("Players on line: ", _players)
