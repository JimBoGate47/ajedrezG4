class_name SpecialSprite extends Node


var _sprite = Sprite2D.new()

func _init(texture: Texture):
	_sprite.texture = texture

func _ready():
	_sprite.region_enabled = true
	add_child(_sprite)

func load_region(region: Rect2):
	_sprite.region_rect = region

func load_position(pos: Vector2):
	_sprite.position = pos

func get_sprite():
	return _sprite
	
func _process(_delta):
	Engine.get_frames_per_second()

func _exit_tree():
	_sprite.queue_free()
