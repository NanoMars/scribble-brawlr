extends CanvasLayer

var controller_id: int
var player_id: int

var is_paused: bool = false

var pause_menu_held_controller_ids: Dictionary[int, Array] = {}

var time_scale_animation_duration: float = 0.15

var time_scale_start: float = 1.0
var time_scale_end: float = 1.0
var time_scale_start_time: float = 0.0

@export var pause_button: int = JOY_BUTTON_START
@export var back_button: int = JOY_BUTTON_B

@export var buttons: Array[Button] = []

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event):
	if event is InputEventJoypadButton:
		if event.pressed:
			var temp_controller_id = event.device

			if temp_controller_id not in pause_menu_held_controller_ids:
					pause_menu_held_controller_ids[temp_controller_id] = []

			if event.button_index == pause_button:
				if controller_id in PlayerManager.joined_players and pause_button not in pause_menu_held_controller_ids[temp_controller_id]:
					
					var temp_player_id: int = PlayerManager.joined_players[temp_controller_id]

					if !is_paused:
						player_id = temp_player_id
						controller_id = temp_controller_id
						show_pause_menu()
					elif is_paused and temp_player_id == player_id:
						hide_pause_menu()
					elif is_paused and temp_player_id != player_id:
						ToastManager.display_toast("Only player " + str(player_id) + " can unpause.") 

					ToastManager.display_toast("temp id " + str(temp_player_id) + "normal id" + str(player_id))
					
				else:
					ToastManager.display_toast("Player trying to pause is not in the game.")
				
			
				if event.button_index not in pause_menu_held_controller_ids[temp_controller_id]:
					pause_menu_held_controller_ids[temp_controller_id].append(event.button_index)
			elif event.button_index == back_button:
				if controller_id in PlayerManager.joined_players:
					var temp_player_id: int = PlayerManager.joined_players[temp_controller_id]
					if is_paused and temp_player_id == player_id and back_button not in pause_menu_held_controller_ids[temp_controller_id]:
						hide_pause_menu()
						ToastManager.display_toast("Unpaused game.")
					elif is_paused and temp_player_id != player_id:
						ToastManager.display_toast("Only player " + str(player_id) + " can unpause.")
		elif not event.pressed:
			var temp_controller_id = event.device

			if temp_controller_id in pause_menu_held_controller_ids and event.button_index in pause_menu_held_controller_ids[temp_controller_id]:
				pause_menu_held_controller_ids[temp_controller_id].erase(event.button_index)
			
			

@export var player_icon: TextureRect

func show_pause_menu():
	is_paused = true
	player_icon.texture = ColourPalette.get_player_texture(player_id - 1)

	time_scale_start = Engine.time_scale
	time_scale_end = 0
	time_scale_start_time = Time.get_ticks_usec()

	visible = true
	
	

	
	

func hide_pause_menu():
	is_paused = false

	time_scale_start = Engine.time_scale
	time_scale_end = 1
	time_scale_start_time = Time.get_ticks_usec()

	visible = false

func _process(delta: float):
	
	var elapsed = (Time.get_ticks_usec() - time_scale_start_time) / 1000000.0

	var t = clamp(elapsed / time_scale_animation_duration, 0.0, 1.0)
	print(lerp(time_scale_start, time_scale_end, t))
	
	Engine.time_scale = lerp(time_scale_start, time_scale_end, t)
