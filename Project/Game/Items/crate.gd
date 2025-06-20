extends Item

@export var break_threshold: float = 30
@export var break_particles_speed_variation: float = 1.5
@export var break_particles_multiplier: float = 1.5
@export var crate_contents: Array[PackedScene] = []

@export var break_sfx: Array[AudioStream] = []
@export var sfx_vol: float = 0.5

func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 5
	self.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	var other_velocity = body.get_linear_velocity() if body.has_method("get_linear_velocity") else Vector2.ZERO
	var relative_velocity = (linear_velocity - other_velocity).length()
	var other_damaging = true if get_tree().get_nodes_in_group("damaging").has(body) else false
	if ((relative_velocity > break_threshold) or other_damaging) and body != recent_holder:
		await get_tree().process_frame
		kill(linear_velocity - other_velocity)

func kill(direction: Vector2 = Vector2.ZERO, _other: Node = null):
	
	var angle = direction.angle()
	direction = Vector2(cos(angle), sin(angle)) * 300 if direction.length() > 300 else direction
	var particles: CPUParticles2D = $CPUParticles2D
	if particles:
		remove_child(particles)
		get_tree().get_root().add_child(particles)
		particles.global_position = global_position
		particles.direction = -direction.normalized()
		particles.initial_velocity_min = direction.length() * break_particles_multiplier
		particles.initial_velocity_max = direction.length() * break_particles_speed_variation * break_particles_multiplier
		particles.emitting = true
	if not break_sfx.is_empty():
		var selected_sfx: AudioStream = break_sfx.pick_random()
		SoundManager.play_sound(selected_sfx, sfx_vol)
	var selected_item: PackedScene = crate_contents.pick_random()
	var item_instance: Node = selected_item.instantiate()
	item_instance.global_position = global_position
	get_tree().get_nodes_in_group("game_root")[0].add_child(item_instance)
	item_instance.linear_velocity = direction
	queue_free()
