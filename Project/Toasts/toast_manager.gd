# toast_manager.gd
extends Node

@onready var toast_scene: PackedScene = preload("res://Toasts/toast.tscn")

var toast_duration: float = 3

var toast_container: Node

var toast_array: Array[Node] = []

func display_toast(toast_string: String) -> void:
	var toast_instance = toast_scene.instantiate()
	get_tree().get_root().add_child(toast_instance)
	toast_array.append(toast_instance)
	toast_instance.duration = toast_duration
	toast_instance.toast_string = toast_string
	toast_instance.show_toast()
	
