extends VBoxContainer

var player_id: int:
	set(value):
		update_loser_scene(value)


func update_loser_scene(id: int) -> void:
	if id < 1 or id > 4:
		return
	
	var loser_texture: Texture = ColourPalette.get_player_texture(id - 1)
	var score: int = PlayerManager.player_scores[id]

	$TextureRect.texture = loser_texture
	$Label.text = str(score)
