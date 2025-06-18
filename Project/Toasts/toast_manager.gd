# toast_manager.gd
extends Node

@onready var toast_window_scene: PackedScene = preload("res://Toasts/toast_window.tscn")
@onready var toast_scene: PackedScene = preload("res://Toasts/toast.tscn")

var toast_container: Node

func _ready() -> void:
	await get_tree().process_frame
	var toast_instance = toast_window_scene.instantiate()
	get_tree().get_root().add_child(toast_instance)
	toast_container = toast_instance.get_node("ToastContainer")

	display_toast("Welcome to the game!")


func display_toast(toast_string: String) -> void:
	var toast_instance = toast_scene.instantiate()
	toast_container.add_child(toast_instance)
	toast_instance.toast_string = toast_string
	toast_instance.show_toast()
	
