# toast.gd
extends PanelContainer

@onready var last_time: float = Time.get_ticks_usec()

@onready var temp_thing: PackedScene = preload("res://Toasts/toast.tscn")

@export var toast_label: Label
var toast_string: String:
	set(value):
		toast_label.text = value
		

func _ready() -> void:
	modulate = Color(1, 1, 1, 1)
	global_position.y = get_viewport().get_visible_rect().size.y + size.y

var animation_duration: float = 0.3
var duration: float = 5


var spring_velocity: float = 0
@export var gap: float = 10
@export var margin: float = -20

@export var spring_strength: float = 1
@export var spring_damping: float = 0.9

var shown: bool = false

func _process(_delta: float) -> void:

	var constant_delta = (Time.get_ticks_usec() - last_time) / 1000000.0
	last_time = Time.get_ticks_usec()
	if not shown:
		return

	var index = ToastManager.toast_array.find(self)
	global_position.x = get_viewport().get_visible_rect().size.x / 2.0 - size.x / 2.0
	var target_position = get_viewport().get_visible_rect().size.y - margin - (index * (size.y)) - (index * gap) - size.y
	

	spring_velocity += (target_position - global_position.y) * spring_strength
	spring_velocity -= spring_velocity * spring_damping
	global_position.y += spring_velocity * constant_delta

func show_toast() -> void:
	if shown:
		return
	shown = true
	await get_tree().create_timer(duration).timeout
	disappear()
	

func disappear() -> void:

	shown = false
	ToastManager.toast_array.erase(self)
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
