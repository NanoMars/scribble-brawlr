extends Item

@export var ammo = 2
var initial_ammo = ammo
var initial_player_look_damping# = holder.look_dampening
var initial_player_look_speed# = holder.look_speed
@export var holding_look_dampening: float = 5
@export var holding_look_speed: float = 30
@onready var raycast: RayCast2D = $RayCast2D
@export var lines: Array[Line2D] = []


func _ready() -> void:
	super._ready()
	for line in lines:
		line.visible = false
		

func press(obstacle_distance: float):
	if ammo > 0:
		for line in lines:
			line.visible = true
		holder.look_dampening = holding_look_dampening
		holder.look_speed = holding_look_speed

func press_held(delta: float, obstacle_distance: float):
	if ammo > 0 and obstacle_distance == -1:
		update_lines()
		pass # draw a red line to indicate aiming draw until it hits an obstacle, might need a raycast for this

func release(obstacle_distance: float):
	holder.look_dampening = initial_player_look_damping
	holder.look_speed = initial_player_look_speed
	for line in lines:
		line.visible = false
	if ammo > 0 and obstacle_distance == -1:
		$gunparticles.emitting = true
		ammo -= 1
		holder.ammo_progress = (float(ammo) / float(initial_ammo)) * 100
		if ammo <= 0:
			depleted = true
		var dir_to_player = (raycast.get_collision_point()  - raycast.global_position).normalized() * -2000
		if raycast.is_colliding():
			var hit = raycast.get_collider()
			if hit and is_instance_valid(hit) and hit.has_method("kill"):
				hit.kill(dir_to_player, self)
			elif hit and is_instance_valid(hit) and hit.has_method("apply_impulse"):
				hit.apply_impulse(-dir_to_player)
		

	
func update_state():
	super.update_state()
	if is_held and holder:
		holder.ammo_progress = (float(ammo) / float(initial_ammo)) * 100
		initial_player_look_damping = holder.look_dampening
		initial_player_look_speed = holder.look_speed
	else:
		for line in lines:
			line.visible = false
func update_lines() -> void:
	var to = to_local(raycast.get_collision_point()) if raycast.is_colliding() else raycast.target_position
	for line in lines:
		line.clear_points()
		line.add_point(Vector2.ZERO)
		line.add_point(to)
