# item.gd
extends RigidBody2D
class_name Item

var is_held := false
var recent_holder: Node = null

var remove_holder_distance: float = 100.0
var holder: Node = null

var depleted: bool = false

@onready var highlight: CPUParticles2D = $ItemHighlightParticle
@onready var despawn_particles: CPUParticles2D = $DespawnParticles

@export var show_ammo_progress: bool = true

var despawn_duration: float = 5.0
var despawn_timer: float = 0.0

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
		highlight.emitting = false
	else:
		PhysicsServer2D.body_set_mode(get_rid(), PhysicsServer2D.BODY_MODE_RIGID)
		collision_layer = 1
		collision_mask = 1
		sleeping = false
		holder = null
		
		highlight.emitting = true if not depleted else false

func _process(delta):
	if recent_holder and recent_holder.global_position.distance_to(global_position) > remove_holder_distance:
		recent_holder = null
	if not is_held and depleted:
		despawn_timer += delta
		if despawn_timer >= despawn_duration:
			remove_child(despawn_particles)
			get_tree().get_nodes_in_group("game_root")[0].add_child(despawn_particles)
			despawn_particles.global_position = global_position
			despawn_particles.emitting = true
			queue_free()
	else:
		despawn_timer = 0.0

func press(obstacle_distance: float):
	pass

func press_held(delta: float, obstacle_distance: float):
	pass
	
func release(obstacle_distance: float):
	pass
