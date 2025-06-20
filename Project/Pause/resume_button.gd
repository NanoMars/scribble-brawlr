extends Button

@export var pause_manager: Node

func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	if pause_manager:
		pause_manager.hide_pause_menu()