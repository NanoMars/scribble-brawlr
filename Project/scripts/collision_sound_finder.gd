extends Node

var collision_sound: AudioStream = preload("res://Audio/impactsounds.tres")
var collision_sound_vol: float = 0.5

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

	
func _connect_body(body: RigidBody2D) -> void:
	body.contact_monitor = true
	body.max_contacts_reported = 5

	if not body.body_entered.is_connected(_on_body_entered.bind(body)):
		body.body_entered.connect(_on_body_entered.bind(body))
		print("connected to body: ", body.name)
	

func _on_body_entered(_body: Node) -> void:#_body_id: int, _body: Node, _body_shape_index: int, _local_shape_index: int) -> void:
	SoundManager.play_sound(collision_sound, collision_sound_vol)
	print("Collision sound played for body: ", _body.name)
	# particle effect to be added
	
