# toast.gd
extends PanelContainer


@onready var temp_thing: PackedScene = preload("res://Toasts/toast.tscn")

@export var toast_label: Label
var toast_string: String:
	set(value):
		toast_label.text = value

func _ready() -> void:
	modulate = Color(1, 1, 1, 1)

var animation_duration: float = 0.3
var duration: float = 5

func show_toast() -> void:
	modulate = Color(1, 1, 1, 1)
	await get_tree().process_frame
	
	var tree = get_tree()
	var container = get_parent()
	
	var clone = temp_thing.instantiate()
	
	container.add_child(clone)
	container.remove_child(self)
	tree.root.add_child(self)
	var assigned_location = clone.global_position
	


	global_position = Vector2(assigned_location.x, 1200)
	#tween from current position to assigned_location

	var tween = create_tween()
	tween.tween_property(self, "global_position", assigned_location, animation_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await tween.finished
	clone.queue_free()
	print("after_tween")
	container.add_child(self)


	await get_tree().create_timer(duration).timeout
	disappear()

func disappear() -> void:
	var tree = get_tree()
	var initial_position = global_position
	var off_screen_position = Vector2(initial_position.x, 1200)  # Assuming 1920/1080 resolution
	
	get_parent().remove_child(self)
	tree.root.add_child(self)
	var tween = get_tree().create_tween()
	# tween from current position to off the screen
	tween.tween_property(self, "global_position", off_screen_position, animation_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	await tween.finished
	queue_free()
