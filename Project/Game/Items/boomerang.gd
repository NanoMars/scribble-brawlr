# boomerang.gd
extends Item
var currently_out: bool = false
var usage_time: float = 0.0
var boomerang_speed: float = 2500.0

var boomerang_instance

@export var usage_duration: float = 6
@export var projectile_script: Script

func press(obstacle_distance: float):
	if not currently_out and usage_time < usage_duration and obstacle_distance == -1:
		boomerang_instance = duplicate()
		boomerang_instance.set_script(projectile_script)
		boomerang_instance.global_position = global_position
		boomerang_instance.rotation = global_rotation
		boomerang_instance.set_meta("kill_owner", holder_player_id)
		boomerang_instance.add_to_group("damaging")
		PhysicsServer2D.body_set_mode(boomerang_instance.get_rid(), PhysicsServer2D.BODY_MODE_RIGID)
		boomerang_instance.collision_layer = 1
		boomerang_instance.collision_mask = 1
		boomerang_instance.sleeping = false
		boomerang_instance.player_node = holder
		
		boomerang_instance.original_boomerang = self

		get_tree().get_nodes_in_group("game_root")[0].add_child(boomerang_instance)
		boomerang_instance.apply_impulse(Vector2(cos(global_rotation), sin(global_rotation)) * boomerang_speed)
		currently_out = true
	pass

func press_held(delta: float, obstacle_distance: float):
	pass

func release(obstacle_distance: float):
	pass

func _process(delta: float) -> void:
	visible = !currently_out if is_held else true
	if currently_out:
		usage_time += delta
		if usage_time >= usage_duration and !currently_out:
			print("kill boomerang")
		if holder:
			holder.ammo_progress = (1 - usage_time / usage_duration) * 100

func update_state():
	super.update_state()
	if is_held and holder:
		holder.ammo_progress = (1 - usage_time / usage_duration) * 100
	await get_tree().process_frame
	if !is_held and currently_out and boomerang_instance and is_instance_valid(boomerang_instance):
		global_rotation = boomerang_instance.global_rotation
		global_position = boomerang_instance.global_position
		linear_velocity = boomerang_instance.linear_velocity
		visible = true
		currently_out = false
		boomerang_instance.queue_free()
