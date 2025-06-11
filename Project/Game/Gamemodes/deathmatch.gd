# deathmatch.gd
extends GameMode

var player_scores: Dictionary = {}

var boxes_spawned: int = 0
@onready var dm_ui: PackedScene = preload("res://Game/Gamemodes/deathmatch_ui.tscn")

func _on_player_died(controller_id: int, player_id: int, killer_player_id: int) -> void:
	if killer_player_id != -1:
		if not player_scores.has(killer_player_id):
			player_scores[killer_player_id] = 0
		player_scores[killer_player_id] += 1
		gamemode_ui_instance.update_score(killer_player_id, player_scores[killer_player_id])
	
	no_tie = not return_tie()

	respawn_player(controller_id, player_id)

func _ready() -> void:
	gamemode_ui = dm_ui
	super._ready()
	load_ui()
	for player_id in PlayerManager.joined_players.values():
		player_scores[player_id] = 0


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
		return -1 
	var max_score = -1
	var winner_id = -1
	for player_id in player_scores.keys():
		if player_scores[player_id] > max_score:
			max_score = player_scores[player_id]
			winner_id = player_id
	return winner_id
