extends CanvasLayer

var controller_id: int
var player_id: int

var is_paused: bool = false

var pause_menu_held_controller_ids: Dictionary[int, Array] = {}

var animation_duration: float = 0.15

var animation_start: float = 1.0
var animation_end: float = 1.0
var animation_start_time: float = 0.0

@export var pause_button: int = JOY_BUTTON_START
@export var back_button: int = JOY_BUTTON_B

@export var buttons: Array[Button] = []

@export var grey_background: ColorRect
@export var ui_stuff: Control

@export var pause_sound: AudioStream
@export var pause_sound_vol: float = 0.5
@export var pause_sound_2: AudioStream
@export var pause_sound_2_vol: float = 0.5
@export var unpause_sound: AudioStream
@export var unpause_sound_vol: float = 0.5

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_child(0).process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event):

	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		var temp_controller_id = event.device
		if is_paused and temp_controller_id != controller_id:
			get_viewport().set_input_as_handled()
			return



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

				if event.button_index not in pause_menu_held_controller_ids[temp_controller_id]:
					pause_menu_held_controller_ids[temp_controller_id].append(event.button_index)

			elif event.button_index == back_button:
				if controller_id in PlayerManager.joined_players:
					var temp_player_id: int = PlayerManager.joined_players[temp_controller_id]
					if is_paused and temp_player_id == player_id and back_button not in pause_menu_held_controller_ids[temp_controller_id]:
						hide_pause_menu()
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

	animation_start = Engine.time_scale
	animation_end = 0
	animation_start_time = Time.get_ticks_usec()
	visible = true

	SoundManager.play_sound(pause_sound, pause_sound_vol, 1.0)
	SoundManager.play_sound(pause_sound_2, pause_sound_2_vol, 1.0)

	await get_tree().process_frame
	if buttons.size() > 0:
		buttons[0].grab_focus()
	for button in buttons:
		button.visible = true
		button.disabled = false
		button.process_mode = Node.PROCESS_MODE_ALWAYS
		button.focus_entered.connect(_on_button_focus_entered)
		button.pressed.connect(_on_button_pressed)
	
	
func _on_button_focus_entered():
	SoundManager.play_navigate_sound()
func _on_button_pressed():
	SoundManager.play_select_sound()

func hide_pause_menu():
	is_paused = false

	animation_start = Engine.time_scale
	animation_end = 1
	animation_start_time = Time.get_ticks_usec()

	SoundManager.play_sound(unpause_sound, unpause_sound_vol, 1.0)

	for button in buttons:
		button.release_focus()

	await get_tree().create_timer(animation_duration).timeout
	visible = false


func _process(_delta: float):
	
	var elapsed = (Time.get_ticks_usec() - animation_start_time) / 1000000.0

	var t = clamp(elapsed / animation_duration, 0.0, 1.0)
	var lerp_t = lerp(animation_start, animation_end, t)
	
	Engine.time_scale = lerp_t
	grey_background.modulate.a = 1 - lerp_t
	ui_stuff.position.y = lerp_t * get_viewport().get_visible_rect().size.y
