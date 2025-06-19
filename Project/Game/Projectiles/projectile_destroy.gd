extends RigidBody2D

@export var break_threshold: float = 30
@export var allowed_existence: float = 5
var existence_timer: float = 0

func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 5
	self.body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	existence_timer += delta
	
	if existence_timer > allowed_existence:
		break_projectile()
	await get_tree().process_frame
	if linear_velocity.length() <= 0.1 and existence_timer > 0.1:
		break_projectile()

func _on_body_entered(body: Node) -> void:
	var other_velocity = body.get_linear_velocity() if body.has_method("get_linear_velocity") else Vector2.ZERO
	var relative_velocity = (linear_velocity - other_velocity).length()
	if relative_velocity > break_threshold and body:
		await get_tree().process_frame
		break_projectile(linear_velocity - other_velocity)

func break_projectile(direction: Vector2 = Vector2.ZERO):
	var particles: CPUParticles2D = get_node_or_null("CPUParticles2D")
	if particles:
		var angle = direction.angle()
		direction = Vector2(cos(angle), sin(angle)) * 300 if direction.length() > 300 else direction
		remove_child(particles)
		get_tree().get_root().add_child(particles)
		particles.global_position = global_position
		particles.emitting = true

		await get_tree().process_frame
		queue_free()
