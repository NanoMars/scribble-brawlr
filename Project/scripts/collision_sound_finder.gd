extends Node

var collision_sound: AudioStream = preload("res://Audio/impactsounds.tres")
var collision_sound_vol: float = 0.5

var tracked_bodies: Array[RigidBody2D] = []

func _ready() -> void:
	get_tree().node_added.connect(_on_node_added)
	_connect_existing_bodies(get_tree().root)
	print("running")

func _on_node_added(node: Node) -> void:
	if node is RigidBody2D:
		_connect_body(node)
		print("connected to body: ", node.name)
	
func _connect_existing_bodies(parent: Node) -> void:
	for child in parent.get_children():
		if child is RigidBody2D:
			_connect_body(child)
			print("connected to existing body: ", child.name)
		_connect_existing_bodies(child)

	
func _connect_body(body: RigidBody2D) -> void:
	body.contact_monitor = true
	body.max_contacts_reported = 5

	if not tracked_bodies.has(body):
		tracked_bodies.append(body)
		print("connected to body: ", body.name)
	

func _physics_process(delta: float) -> void:
	for body in tracked_bodies:
		if not is_instance_valid(body):
			continue
		if body.get_contact_count() > 0:
			print("Body ", body.name, " has contacts: ", body.get_contact_count())
			var og_contact_count = body.get_contact_count()
			await get_tree().process_frame
			if body.get_contact_count() < og_contact_count:
				SoundManager.play_sound(collision_sound, collision_sound_vol)
			
			# for i in range(body.get_contact_count()):
			# 	var collider = body.get_contact_collider(i)
			# 	if collider and is_instance_valid(collider):
			# 		SoundManager.play_sound(collision_sound, collision_sound_vol)

					
				

				
