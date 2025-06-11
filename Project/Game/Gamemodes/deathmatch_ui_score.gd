extends VBoxContainer

@export var score_label: Label
@export var icon_rect: TextureRect

@export var angle_variance: float = 10
var offset: float = 0.0
@export var settle_speed: float = 0.1
@export var offset_ammount: float = 0.3

var player_id: int = 1

	

func update_score(score: int) -> void:
	if score_label and icon_rect and player_id != -1:
		score_label.text = str(score)
		#icon_rect.texture = 
		score_label.pivot_offset = score_label.size / 2
		score_label.rotation = randf_range(-angle_variance, angle_variance) * (PI / 180.0)
		offset = offset_ammount

func _ready():
	update_score(0)

func _process(delta: float) -> void:
	if offset > 0.1:
		offset -= (offset / settle_speed) * delta
		score_label.scale.x = 1 + offset
		score_label.scale.y = 1 + offset

func update_texture() -> void:
	if icon_rect:
		var texture = ColourPalette.get_player_texture(player_id - 1)
		icon_rect.texture = texture