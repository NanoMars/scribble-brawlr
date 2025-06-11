extends Control

@export var score_ui: PackedScene
@export var score_ui_container: Control
@export var clock_label: Label

func _ready() -> void:
	for player_id in PlayerManager.joined_players.values():
		var score_ui_instance = score_ui.instantiate()
		score_ui_instance.player_id = player_id
		score_ui_container.add_child(score_ui_instance)
		score_ui_instance.update_score(0)
		score_ui_instance.update_texture()
	
	position = Vector2(0, 0)



func update_score(player_id: int, score: int) -> void:
	for child in score_ui_container.get_children():
		if child.player_id == player_id:
			child.update_score(score)
			return

	