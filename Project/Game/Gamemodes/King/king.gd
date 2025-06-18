# king.gd
extends GameMode

var player_scores: Dictionary = {}

var boxes_spawned: int = 0
@onready var crown_scene: PackedScene = preload("res://Game/Gamemodes/King/Crown.tscn")

var king_ui: PackedScene = preload("res://Game/Gamemodes/King/king_UI.tscn")
var crown: Node = null

@export var time_goal: int = 30

func _on_player_died(controller_id: int, player_id: int, killer_player_id: int) -> void:
	
	respawn_player(controller_id, player_id)

func _ready() -> void:
	
	gamemode_ui = king_ui
	super._ready()
	load_ui()
	for player_id in PlayerManager.joined_players.values():
		player_scores[player_id] = 0
	var object_spawner_instance = object_spawner_scene.instantiate()
	object_spawner_instance.global_position = Vector2(1920.0 / 2, 1080.0 / 2)
	get_tree().get_nodes_in_group("game_root")[0].add_child(object_spawner_instance)
	object_spawner_instance.spawn_object(1, crown_scene)


func crown_scored(player_id: int):
	if not player_scores.has(player_id):
		player_scores[player_id] = 0
	player_scores[player_id] += 1
	gamemode_ui_instance.update_score(player_id, player_scores[player_id])
	
	no_tie = not return_tie()
	if player_scores[player_id] >= time_goal:
		define_winner(player_id)
	
	

func return_tie() -> bool:
	if player_scores.size() >= 2:
		var temp_scores = player_scores.values()
		temp_scores.sort()
		temp_scores.reverse()
		if temp_scores[0] == temp_scores[1]:
			return true
	return false

func return_winner():
	if return_tie():
		return -1  # No winner in case of a tie
	var max_score = -1
	var winner_id = -1
	for player_id in player_scores.keys():
		if player_scores[player_id] > max_score:
			max_score = player_scores[player_id]
			winner_id = player_id
	return winner_id
