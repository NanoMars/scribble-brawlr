extends Node

@export var maps: Array[PackedScene] = [
	preload("res://Game/Maps/Map 1.tscn"),
	preload("res://Game/Maps/Map 2.tscn"),
	preload("res://Game/Maps/Map 3.tscn"),
]

@export var game_modes: Dictionary[Script, Texture] = {
	preload("res://Game/Gamemodes/deathmatch.gd"): preload("res://Assets/SplashScreens/deathmatch.png"),
	preload("res://Game/Gamemodes/King/king.gd"): preload("res://Assets/SplashScreens/King (1).png"),
	preload("res://Game/Gamemodes/Tank/tank.gd"): preload("res://Assets/SplashScreens/tank.png"),
}

func start_game_round(map: PackedScene = null, game_mode: Script = null) -> void:
	if map == null:
		map = maps.pick_random()
	if game_mode == null:
		game_mode = game_modes.keys().pick_random()
	

	var new_scene = map.instantiate()
	new_scene.set_script(game_mode)
	get_tree().root.add_child(new_scene)
	get_tree().current_scene.queue_free()
	get_tree().current_scene = new_scene
