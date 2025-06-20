extends Button

@export var main_menu_scene: PackedScene

func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	if main_menu_scene:
		Engine.time_scale = 1.0
		get_tree().change_scene_to_packed(main_menu_scene)
