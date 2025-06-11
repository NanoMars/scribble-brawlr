# join_label.gd
extends ColorRect

func _enter_tree() -> void:
	var parent := get_parent()
	if parent:
		parent.move_child(self, -1)
	parent.child_order_changed.connect(_ensure_last_child)

func _ensure_last_child() -> void:
	var parent := get_parent()
	if parent and parent.get_child(parent.get_child_count() - 1) != self:
		parent.move_child(self, parent.get_child_count() - 1)