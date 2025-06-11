# boomerang_projectile_script.gd
extends RigidBody2D

var speed: float = 5000
var speed_increase: float = 15000
var original_boomerang
var left_distance = false

var player_node

func _process(delta):
	if player_node == null:
		return

	var vector_to_player: Vector2 = player_node.global_position - global_position


	if vector_to_player.length() < 60 and left_distance:
		original_boomerang.currently_out = false
		#original_boomerang.boomerang_instance = null
		queue_free()
		return
	elif vector_to_player.length() > 60 or !player_node:
		left_distance = true

	speed += speed_increase * delta
	
	apply_impulse(vector_to_player.normalized() * speed * delta)
	angular_velocity = 50
