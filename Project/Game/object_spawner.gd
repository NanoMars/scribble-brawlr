extends Marker2D


@onready var progress_bar: RadialProgress = $RadialProgress
@export var default_object_scene: PackedScene


func _ready() -> void:
	progress_bar.visible = false

func spawn_object(spawn_time: float, object_scene: PackedScene = default_object_scene):
	object_scene = object_scene if object_scene and object_scene != null else default_object_scene
	progress_bar.scale = Vector2.ZERO

	var bounce_in: Tween = create_tween()
	bounce_in.tween_property(progress_bar, "scale", Vector2.ONE, spawn_time / 6).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)

	progress_bar.visible = true
	progress_bar.progress = 0.0

	await progress_bar.animate(spawn_time)

	var object_instance: Node2D = object_scene.instantiate()
	object_instance.global_position = global_position
	object_instance.rotation = randf() * 2 * PI
	get_tree().get_nodes_in_group("game_root")[0].add_child(object_instance)

	call_deferred("_bounce_out")
	return object_instance

	

func _bounce_out() -> void:
	var bounce_out: Tween = create_tween()
	bounce_out.tween_property(progress_bar, "scale", Vector2.ZERO, 0.5).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_IN)
	await bounce_out.finished
	queue_free()
