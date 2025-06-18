# player_section.gd
extends NinePatchRect

var controller_id: int = -1
var player_id: int = -1
var loaded: bool = false

var start_button_held: bool = true
var leave_button_held: bool = true

var spring_velocity: float = 0.0

@export var spring_strength: float = 0.9
@export var spring_dampening: float = 0.2

@export var player_label: Label
@export var press_start_label: Label

@export var texture_colors: Array[Texture] = [null, null, null, null]

func _ready() -> void:
	PlayerManager.player_id_changed.connect(_on_player_id_changed)
	size_flags_stretch_ratio = 0.0

func _process(_delta: float) -> void:
	if controller_id == -1 or player_id == -1:
		return
	
	if not loaded and controller_id != -1 and player_id != -1:
		loaded = true
		update_labels()
		

	if Input.is_joy_button_pressed(controller_id, JOY_BUTTON_A):
		if not start_button_held and PlayerManager.joined_players.size() >= 2 and player_id == 1:
			GameManager.start_game_round()
		elif not start_button_held and not PlayerManager.joined_players.size() >= 2 and player_id == 1:
			ToastManager.display_toast("Not enough players to start!")
		elif not start_button_held and player_id != 1:
			ToastManager.display_toast("Only Player 1 can start the game!")
		if not start_button_held:
			start_button_held = true

	else:
		start_button_held = false


	if Input.is_joy_button_pressed(controller_id, JOY_BUTTON_B):
		if not leave_button_held:
			PlayerManager.leave_player(controller_id)
			queue_free()
			leave_button_held = true
	else:
		leave_button_held = false

func _physics_process(delta: float) -> void:
	spring_velocity += (1 - size_flags_stretch_ratio) * spring_strength * delta
	spring_velocity -= spring_velocity * spring_dampening * delta
	size_flags_stretch_ratio += spring_velocity * delta

func _on_player_id_changed(cid: int, pid: int) -> void:
	if cid == self.controller_id:
		player_id = pid
	update_labels()

func update_labels() -> void:
	player_label.text = "Player " + str(player_id)
	
	if player_id == 1 and PlayerManager.joined_players.size() >= 2:
		press_start_label.text = "Press A to start or B to leave"
	else:
		press_start_label.text = "Press B to leave"

	texture = texture_colors[player_id - 1]
