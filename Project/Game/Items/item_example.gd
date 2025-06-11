extends Item

func press(obstacle_distance: float):
	$CPUParticles2D.emitting = true

func press_held(delta: float, obstacle_distance: float):
	pass

func release(obstacle_distance: float):
	pass
	
func update_state():
	super.update_state()
	if is_held and holder:
		holder.ammo_progress = 100