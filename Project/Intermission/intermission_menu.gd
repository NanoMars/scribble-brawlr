extends Control

@export var highres_player_textures: Array[Texture]

@export var winner_icon: TextureRect
@export var winner_label: Label
@export var banner_label: Label
@export var loser_scene: PackedScene
@export var loser_container: Control
@export var countdown_label: Label
@export var countdown_duration: float = 10
@onready var countdown_timer: float = countdown_duration
@export var game_banner: TextureRect

@export var maps: Array[PackedScene]
@export var game_modes: Dictionary[Script, Texture]

@onready var picked_map: PackedScene = maps.pick_random()
@onready var picked_game_mode: Script = game_modes.keys().pick_random()
@onready var game_banner_texture: Texture = game_modes[picked_game_mode]

@export var main_menu_screen: PackedScene

@onready var player_scores: Dictionary[int, int] = PlayerManager.player_scores
@onready var joined_players: Dictionary[int, int] = PlayerManager.joined_players
@onready var winner_id: int = PlayerManager.previous_winner_id

var leave_button_held: bool = true


func _ready() -> void:
	game_banner.texture = game_banner_texture
	winner_icon.texture = highres_player_textures[winner_id - 1]
	winner_label.text = str(player_scores[winner_id])

	var winner_colour_string: String
	match winner_id:
		1: 
			winner_colour_string = "Red"
		2: 
			winner_colour_string = "Purple"
		3: 
			winner_colour_string = "Yellow"
		4: 
			winner_colour_string = "Green"
		_: 
			winner_colour_string = "Red"
	

	banner_label.text = winner_colour_string + " Wins!"
	for player in player_scores:
		var player_id = player
		if player_id != winner_id:
			var loser_instance = loser_scene.instantiate()
			loser_instance.player_id = player_id
			loser_container.add_child(loser_instance)

func _process(delta):
	countdown_timer = max(countdown_timer - delta, 0)
	countdown_label.text = "in " + str(int(countdown_timer))

	if countdown_timer <= 0:
		#get_tree().change_scene_to_packed(maps.pick_random())
		var new_scene = picked_map.instantiate()
		new_scene.set_script(picked_game_mode)
		get_tree().root.add_child(new_scene)
		get_tree().current_scene.queue_free()
		get_tree().current_scene = new_scene
		

		return

	var controller_id: int = -1
	for id in PlayerManager.joined_players:
		if PlayerManager.joined_players[id] == 1:
			controller_id = id
			break
	
	if Input.is_joy_button_pressed(controller_id, JOY_BUTTON_B):
		if not leave_button_held:
			PlayerManager.reset_scores()
			get_tree().change_scene_to_packed(main_menu_screen)
			leave_button_held = true
	else:
		leave_button_held = false
