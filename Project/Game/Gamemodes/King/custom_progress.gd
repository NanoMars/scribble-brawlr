@tool
extends PanelContainer

@export var max_value: float:
	set(new_value):
		_max_value = max(new_value, min_value)
		update()
	get:
		return _max_value
var _max_value: float = 100.0
@export var min_value: float:
	set(new_value):
		_min_value = min(new_value, max_value)
		update()
	get:
		return _min_value

var _min_value: float = 0.0

@onready var progress_filled: Control = $MarginContainer/PanelContainer/HBoxContainer/PanelContainer
@onready var progress_empty: Control = $MarginContainer/PanelContainer/HBoxContainer/Control

var _value: float = 0.0
@export var value: float:
	set(new_value):
		_value = clamp(new_value, min_value, max_value)
		update()
	get:
		return _value

func update():
	if not get_tree():
		return
	var value_normalized = (value - min_value) / (max_value - min_value)
	value_normalized = clamp(value_normalized, 0.0, 1.0)
	progress_filled.size_flags_stretch_ratio = value_normalized
	progress_empty.size_flags_stretch_ratio = 1.0 - value_normalized
