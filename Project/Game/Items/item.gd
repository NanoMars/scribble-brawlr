# item.gd
extends RigidBody2D
class_name Item

var is_held := false
var recent_holder: Node = null

var remove_holder_distance: float = 100.0
var holder: Node = null

@export var show_ammo_progress: bool = true

var holder_player_id: int:
	get:
		if holder:
			return holder.player_id
		return -1

	
var holder_controller_id: int:
	get:
		if holder:
			return holder.controller_id
		return -1

func _ready():
	update_state()

func set_held_state(held: bool):
	is_held = held
	update_state()

func update_state():
	if is_held:
		PhysicsServer2D.body_set_mode(get_rid(), PhysicsServer2D.BODY_MODE_STATIC)
		collision_layer = 0
		collision_mask = 0
		sleeping = true
		holder = get_parent().get_parent()
	else:
		PhysicsServer2D.body_set_mode(get_rid(), PhysicsServer2D.BODY_MODE_RIGID)
		collision_layer = 1
		collision_mask = 1
		sleeping = false
		holder = null

func _process(_delta):
	if recent_holder and recent_holder.global_position.distance_to(global_position) > remove_holder_distance:
		recent_holder = null

func press(obstacle_distance: float):
	pass

func press_held(delta: float, obstacle_distance: float):
	pass
	
func release(obstacle_distance: float):
	pass
