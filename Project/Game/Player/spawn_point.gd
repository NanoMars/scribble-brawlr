extends Marker2D

@export_enum("red", "purple", "yellow", "green") var player_color: int = 0

@onready var progress_bar: RadialProgress = $RadialProgress
@export var player_scene: PackedScene 

func _ready() -> void:
	progress_bar.bar_color = ColourPalette.get_colour(player_color)
	progress_bar.visible = false

func spawn_player(spawn_time: float, player_id: int, controller_id: int):
	
	progress_bar.scale = Vector2.ZERO

	var bounce_in: Tween = create_tween()
	bounce_in.tween_property(progress_bar, "scale", Vector2.ONE, spawn_time / 6).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)

	progress_bar.visible = true
	progress_bar.progress = 0.0

	await progress_bar.animate(spawn_time)

	var player_instance: Node2D = player_scene.instantiate()
	player_instance.controller_id = controller_id
	player_instance.player_id = player_id
	player_instance.global_position = global_position
	get_tree().get_nodes_in_group("game_root")[0].add_child(player_instance)

	call_deferred("_bounce_out")
	return player_instance

	

func _bounce_out() -> void:
	var bounce_out: Tween = create_tween()
	bounce_out.tween_property(progress_bar, "scale", Vector2.ZERO, 0.5).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_IN)
	await bounce_out.finished

	progress_bar.visible = false
