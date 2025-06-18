# toast_manager.gd
extends Node

@onready var toast_window_scene: PackedScene = preload("res://Toasts/toast_window.tscn")
@onready var toast_scene: PackedScene = preload("res://Toasts/toast.tscn")

var toast_duration: float = 100

var toast_container: Node

var toast_array: Array[Node] = []

func _ready() -> void:
	await get_tree().process_frame
	var toast_instance = toast_window_scene.instantiate()
	get_tree().get_root().add_child(toast_instance)
	toast_container = toast_instance.get_node("ToastContainer")

	
	for i in range(500):
		await get_tree().create_timer(0.3).timeout
		display_toast("Toast number %d" % i)


func display_toast(toast_string: String) -> void:
	var toast_instance = toast_scene.instantiate()
	get_tree().get_root().add_child(toast_instance)
	toast_array.append(toast_instance)
	toast_instance.duration = toast_duration
	toast_instance.toast_string = toast_string
	toast_instance.show_toast()
	
