extends Item

@export var temperature: float = 0.0
@export var max_temperature: float = 100.0
@export var temperature_increase_rate: float = 10.0
@export var temperature_decrease_rate: float = 25.0

@export var projectile_speed: float = 1000.0
@export var projectile_scene: PackedScene

@export var fire_rate: float = 0.1
@export var fire_timer: float = 0.0


var overheated: bool = false

var button_held: bool = false

func press(_obstacle_distance: float):
	#$CPUParticles2D.emitting = true
	button_held = true

func release(_obstacle_distance: float):
	button_held = false
	
			

func _process(delta: float) -> void:
	super._process(delta)
	if !button_held:
		temperature = max(0.0, temperature - temperature_decrease_rate * delta)

func press_held(delta: float, obstacle_distance: float):
	if not overheated and obstacle_distance == -1:
		temperature = min(max_temperature, temperature + temperature_increase_rate * delta)
		if temperature >= max_temperature:
			overheated = true
		else:
			fire_timer += delta
			if fire_timer >= fire_rate:
				fire_timer = 0.0
				var projectile: Node2D = projectile_scene.instantiate()
				get_tree().get_nodes_in_group("game_root")[0].add_child(projectile)
				projectile.global_position = global_position
				projectile.rotation = global_rotation
				projectile.set_meta("kill_owner", holder_player_id)
				projectile.apply_impulse(Vector2(cos(global_rotation), sin(global_rotation)) * projectile_speed)
				
				


		

			
	

func update_state():
	super.update_state()
	# if is_held:
	# 	holder.ammo_progress = (float(ammo) / float(initial_ammo)) * 100