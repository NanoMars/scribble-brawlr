extends Item

@export var temperature: float = 0.0
@export var max_temperature: float = 100.0
@export var temperature_increase_rate: float = 10.0
@export var temperature_decrease_rate: float = 25.0

@export var projectile_speed: float = 1000.0
@export var projectile_scene: PackedScene

@export var fire_rate: float = 0.1
@export var fire_timer: float = 0.0
@export var fire_angle_variance: float = 0.1


@export var holding_look_dampening: float = 5
@export var holding_look_speed: float = 30

var initial_player_look_damping# = holder.look_dampening
var initial_player_look_speed# = holder.look_speed

var overheated: bool = false
@export var overheat_sound: AudioStream
@export var overheat_vol: float = 0.3

@export var shoot_sound: AudioStream
@export var shoot_vol: float = 0.5

var button_held: bool = false

@onready var sprite: Sprite2D = $Sprite2D



func press(_obstacle_distance: float):
	#$CPUParticles2D.emitting = true
	button_held = true

func release(_obstacle_distance: float):
	button_held = false
	

func _process(delta: float) -> void:
	super._process(delta)
	if !button_held or !is_held or overheated:
		temperature = max(0.0, temperature - temperature_decrease_rate * delta)
		if temperature <= 0:
			overheated = false
		if holder and temperature > 0:
			holder.ammo_progress = (temperature / max_temperature) * 100

	var overheat_progress = temperature / max_temperature
	
	sprite.modulate = Color(1.0, 1.0 - overheat_progress, 1.0 - overheat_progress, 1.0)

func press_held(delta: float, obstacle_distance: float):
	if not overheated and obstacle_distance == -1 and button_held and is_held:
		
		if temperature >= max_temperature:
			overheated = true
			button_held = false
			SoundManager.play_sound(overheat_sound, overheat_vol)
		else:
			fire_timer += delta
			if fire_timer >= fire_rate:
				if shoot_sound:
					SoundManager.play_sound(shoot_sound, shoot_vol)
				temperature = min(max_temperature, temperature + (temperature_increase_rate * fire_rate))
				holder.ammo_progress = (temperature / max_temperature) * 100
				fire_timer = 0.0
				var projectile: Node2D = projectile_scene.instantiate()
				get_tree().get_nodes_in_group("game_root")[0].add_child(projectile)
				projectile.global_position = global_position
				projectile.rotation = global_rotation + randf_range(-fire_angle_variance, fire_angle_variance)
				projectile.set_meta("kill_owner", holder_player_id)
				projectile.apply_impulse(Vector2(cos(projectile.rotation), sin(projectile.rotation)) * projectile_speed)

func update_state():
	super.update_state()
	# if is_held:
	# 	holder.ammo_progress = (float(ammo) / float(initial_ammo)) * 100
	if is_held and holder:
		initial_player_look_damping = holder.look_dampening
		initial_player_look_speed = holder.look_speed
		holder.look_dampening = holding_look_dampening
		holder.look_speed = holding_look_speed
	elif not is_held and most_recent_holder:
		most_recent_holder.look_dampening = initial_player_look_damping
		most_recent_holder.look_speed = initial_player_look_speed
