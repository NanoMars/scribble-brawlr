# toast.gd
extends PanelContainer

@export var toast_label: Label
var toast_string: String:
	set(value):
		toast_label.text = value
var duration: float = 3.0

func show_toast() -> void:
	var tree = get_tree()
	var container = get_parent()
	var assigned_location = global_position
	container.remove_child(self)
	tree.root.add_child(self)
	

	global_position = Vector2(assigned_location.x, 1200)
	toast_label.text = toast_string
	#tween from current position to assigned_location
	print("before_tween")
	var tween = create_tween()
	tween.tween_property(self, "global_position", assigned_location, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await tween.finished
	print("after_tween")
	container.add_child(self)
	#disappear()

func disappear() -> void:
	var tween = get_tree().create_tween()
	# tween from current position to off the screen
