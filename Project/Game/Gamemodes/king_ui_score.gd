extends VBoxContainer

@export var control_thing: Control
@export var icon_rect: TextureRect
@export var goal_label: Label

@export var angle_variance: float = 10
var offset: float = 0.0
@export var settle_speed: float = 0.1
@export var offset_ammount: float = 0.3

@export var progress_thing: Control

var player_id: int = 1

var goal: int:
	set(value):
		goal_label.text = str(value)
		progress_thing.max_value = value
		_goal = value
	get:
		return _goal
var _goal: int = 30
	

func update_score(score: int) -> void:
	if control_thing and icon_rect and player_id != -1:
		progress_thing.value = score
		#icon_rect.texture = 
		control_thing.pivot_offset = control_thing.size / 2
		control_thing.rotation = randf_range(-angle_variance, angle_variance) * (PI / 180.0)
		offset = offset_ammount

func _ready():
	update_score(0)

func _process(delta: float) -> void:
	if offset > 0.1:
		offset -= (offset / settle_speed) * delta
		control_thing.scale.x = 1 + offset
		control_thing.scale.y = 1 + offset

func update_texture() -> void:
	if icon_rect:
		var texture = ColourPalette.get_player_texture(player_id - 1)
		icon_rect.texture = texture