extends Node

var red := Color("#FC5C65")
var purple := Color("#9179FF")
var yellow := Color("#FFB601")
var green := Color("#38D98B")

@onready var red_texture = preload("res://Assets/Characters/red_character.png")
@onready var purple_texture = preload("res://Assets/Characters/purple_character.png")
@onready var yellow_texture = preload("res://Assets/Characters/yellow_character.png")
@onready var green_texture = preload("res://Assets/Characters/green_character.png")

func get_colour(index: int) -> Color:
	match index:
		0: return red
		1: return purple
		2: return yellow
		3: return green
		_: return red

func get_player_texture(index: int) -> Texture:
	match index:
		0: return red_texture
		1: return purple_texture
		2: return yellow_texture
		3: return green_texture
		_: return red_texture