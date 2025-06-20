# player.gd
extends CharacterBody2D
var controller_id: int = -1
var _player_id: int = -1
var player_id : int :
	get:
		return _player_id
	set(value):
		if value != _player_id:
			_player_id = value
			call_deferred("update_colour")
			
const DEADZONE := 0.1

var current_item: Node = null

var item_marker: Marker2D 

var dropped_items: Array = []

var ammo_show_timer: float = 0
@export var ammo_reset_duration: float = 3

var ammo_progress: float:
	set(value):
		ammo_progress_internal = value
		ammo_show_timer = ammo_reset_duration

var ammo_progress_internal: float = 100

@onready var ammo_progress_bar: ProgressBar = $Node2D/ProgressBar

@export var movement_speed := 200.0
@export var acceleration := 1000.0
@export var friction := 500.0

@export var use_button: int = JOY_AXIS_TRIGGER_RIGHT
@export var drop_button: int = JOY_BUTTON_B

@export var pick_up_collision_shape: CollisionShape2D

@export var drop_impulse_strength: float = 200.0
@export var max_drop_time := 0.5
@export var hold_drop_multiplier := 16

@export var death_particles_speed_variation: float = 2
@export var kill_velocity_threshold: float = 400.0

@onready var hand1: Sprite2D = $Hand1
@onready var hand2: Sprite2D = $Hand2
@onready var body_sprite: Sprite2D = $Sprite2D
@onready var blood_particles: CPUParticles2D = $CPUParticles2D

@onready var raycast: RayCast2D = $RayCast2D

@export var player_textures: Array[Texture] = [null, null, null, null]
@export var hand_textures: Array[Texture] = [null, null, null, null]
@export var blood_textures: Array[Texture] = [null, null, null, null]

@export var pickup_sfx: AudioStream
@export var pickup_sfx_vol: float = 0.5

@export var death_sound: AudioStream
@export var death_sound_vol: float = 0.3

@export var footstep_sounds: Array[AudioStream] = []
@export var footstep_sound_vol: float = 0.8
@export var footstep_distance_threshold: float = 50.0
var distance_since_last_footstep: float = 0.0
@onready var last_position: Vector2 = global_position

var dead: bool = false

var holding_use := false
var holding_drop := false

var holding_drop_time := 0.5

signal died(controller_id: int, player_id: int, kill_attribution_player_id: int)


var look_velocity: float = 0
@export var look_dampening: float = 1
@export var look_speed: float = 10
var goal_look: float = 0

func _ready() -> void:
	item_marker = $Marker2D
	set_meta("kill_owner", player_id)

func update_ammo_display(delta: float):
	if !ammo_progress_bar:
		return
	ammo_progress_bar.value = ammo_progress_internal

	ammo_show_timer = max(ammo_show_timer - delta, 0)
	ammo_progress_bar.visible = (!ammo_show_timer == 0 or ammo_progress_internal <= 1) and current_item and current_item.show_ammo_progress

func _physics_process(delta):
	# Movement and aiming
	var move_input: Vector2 = Vector2(
		Input.get_joy_axis(controller_id, JOY_AXIS_LEFT_X),
		Input.get_joy_axis(controller_id, JOY_AXIS_LEFT_Y)
	)
	if move_input.length() > DEADZONE:
		velocity = velocity.move_toward(
			move_input.normalized() * movement_speed,
			acceleration * delta
		)
	else:
		velocity = velocity.move_toward(
			Vector2.ZERO,
			friction * delta
		)

	move_and_slide()
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider.has_method("get_linear_velocity"):
			var other_velocity = collider.get_linear_velocity()
			var other_damaging = true if get_tree().get_nodes_in_group("damaging").has(collider) else false
			var other_harmless = true if get_tree().get_nodes_in_group("harmless").has(collider) else false
			if other_damaging and not other_harmless:
				await get_tree().process_frame
				kill(velocity - other_velocity, collider)


	var aim_input: Vector2 = Vector2(
		Input.get_joy_axis(controller_id, JOY_AXIS_RIGHT_X),
		Input.get_joy_axis(controller_id, JOY_AXIS_RIGHT_Y)
	)
	if aim_input.length() > DEADZONE:
		goal_look = aim_input.angle()
	elif move_input.length() > DEADZONE:
		goal_look = move_input.angle()
	
	var angle_diff = wrapf(goal_look - rotation, -PI, PI)
	look_velocity += angle_diff * delta * look_speed
	look_velocity /= look_dampening
	rotation += look_velocity

	# Item interaction
	var raycast_distance = get_raycast_distance()
	if Input.get_joy_axis(controller_id, use_button) > 0.5:
		if current_item:
			if not holding_use :
				current_item.press(raycast_distance)
			current_item.press_held(delta, raycast_distance)
		holding_use = true
	else:
		if current_item and holding_use:
			current_item.release(raycast_distance)
		holding_use = false

	if Input.is_joy_button_pressed(controller_id, drop_button):
		holding_drop = true
		holding_drop_time += delta
	else:
		if current_item and holding_drop:
			drop_item(holding_drop_time)
		holding_drop = false
		holding_drop_time = 0.0

func _process(delta: float) -> void:
	distance_since_last_footstep += global_position.distance_to(last_position)
	if distance_since_last_footstep >= footstep_distance_threshold and not dead:
		distance_since_last_footstep = 0.0
		if footstep_sounds.size() > 0:
			var sound = footstep_sounds.pick_random()
			SoundManager.play_sound(sound, footstep_sound_vol)
	last_position = global_position

	update_ammo_display(delta)
	for item in dropped_items:
		if item.global_position.distance_to(global_position) > pick_up_collision_shape.shape.get_radius():
			dropped_items.erase(item)
			break

func _on_body_entered(body: Node):
	
	var other_velocity = body.get_linear_velocity() if body.has_method("get_linear_velocity") else Vector2.ZERO
	var relative_velocity = (velocity - other_velocity).length()
	var other_meta = body.get_meta("kill_owner") if body.has_meta("kill_owner") else null
	var other_harmless = true if get_tree().get_nodes_in_group("harmless").has(body) else false
	if current_item == null and body is Item and not dropped_items.has(body) and not (relative_velocity >= kill_velocity_threshold and other_meta != player_id):
		pick_up_item(body)
	if (relative_velocity >= kill_velocity_threshold and other_meta != player_id) and not other_harmless:
		await get_tree().process_frame
		kill(velocity - other_velocity, body)

func pick_up_item(item: Node):
	current_item = item
	call_deferred("_finalize_pick_up", item)

func _finalize_pick_up(item: Node):
	if pickup_sfx:
		SoundManager.play_sound(pickup_sfx, pickup_sfx_vol)
	item.get_parent().remove_child(item)
	item_marker.add_child(item)
	item.position = Vector2.ZERO
	item.rotation = 0
	current_item.set_meta("kill_owner", player_id)



	

	current_item.set_held_state(true)
	

func drop_item(speed: float = 0.0):
	if not current_item:
		return

	speed = (max(min(speed, max_drop_time), 0.0) * hold_drop_multiplier) + 1

	current_item.recent_holder = self
	current_item.set_held_state(false)
	var item = current_item
	current_item = null
	if item.get_parent():
		item.get_parent().remove_child(item)
	get_tree().get_nodes_in_group("game_root")[0].add_child(item)
	var distance = item_marker.global_position.distance_to(global_position)
	item.global_position = global_position + Vector2(cos(rotation), sin(rotation)) * distance
	item.rotation = rotation
	item.apply_impulse(Vector2(cos(rotation), sin(rotation)) * drop_impulse_strength * speed)
	dropped_items.append(item)

func kill(direction: Vector2 = Vector2.ZERO, other: Node = null):
	if dead:
		return
	dead = true
	var angle = direction.angle()
	direction = Vector2(cos(angle), sin(angle)) * 300 if direction.length() > 300 else direction
	var particles: CPUParticles2D = $CPUParticles2D
	remove_child(particles)
	get_tree().get_root().add_child(particles)
	particles.global_position = global_position
	particles.direction = -direction.normalized()
	particles.initial_velocity_min = direction.length()
	particles.initial_velocity_max = direction.length() * death_particles_speed_variation
	particles.emitting = true
	drop_item(0.0)

	SoundManager.play_sound(death_sound, death_sound_vol)

	if other != null and other.get_meta("kill_owner") != null:
		var killer_player_id = other.get_meta("kill_owner")
		if killer_player_id != player_id and killer_player_id != -1:
			emit_signal("died", controller_id, player_id, killer_player_id)
	else:
		emit_signal("died", controller_id, player_id, -1)
	queue_free()
	
func update_colour():
	if player_id == -1 or body_sprite == null or hand1 == null or hand2 == null or blood_particles == null:
		return
	body_sprite.texture = player_textures[player_id - 1]
	hand1.texture = hand_textures[player_id - 1]
	hand2.texture = hand_textures[player_id - 1]
	var stylebox := StyleBoxFlat.new()
	stylebox.bg_color = ColourPalette.get_colour(player_id - 1)
	ammo_progress_bar.add_theme_stylebox_override("fill", stylebox)
	blood_particles.texture = blood_textures[player_id - 1]
	
func get_raycast_distance() -> float:
	var collider = raycast.get_collider()
	if raycast.is_colliding() and collider and collider.is_in_group("obstacles"):
		return raycast.get_collision_point().distance_to(global_position)
	else:
		return -1.0
