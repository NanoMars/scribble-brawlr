extends Node

func _ready() -> void:
	_connect_to_all_collision_objects()
	get_tree().node_added.connect(_on_node_added)

func _connect_to_all_collision_objects() -> void

