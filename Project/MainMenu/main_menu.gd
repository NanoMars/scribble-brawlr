extends Control

var held_keys: Array = []

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode not in held_keys:
			held_keys.append(event.keycode)
			ToastManager.display_toast("Controller only!")
		elif not event.pressed and event.keycode in held_keys:
			held_keys.erase(event.keycode)
