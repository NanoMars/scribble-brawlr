extends RigidBody2D

@onready var area: Area2D = $Area2D
var following: Node = null
@export var speed: float = 1.0
@export var angular_speed: float = 5
@export var close_distance: float = 100.0
@export var offset: Vector2 = Vector2.ZERO
@export var angle_offset: float = -90


@export var idle_speed: float = 5000.0
@export var idle_angle_speed: float = 50.0

@onready var score_timer: float = score_duration
var score_duration: float = 1

@onready var game_root: Node = get_tree().get_nodes_in_group("game_root")[0]

@onready var follow_line: Line2D = $Line2D
var current_point: int = 0
func _ready() -> void:
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)
	follow_line.position = global_position

var crown_dibs: Array[Node] = []

func _on_body_entered(body: Node) -> void:
	print("Crown: Body entered: ", body.name)
	if body is CharacterBody2D:
		if not following:
			following = body	
			body.tree_exiting.connect(_disconnect)
		else:
			if body not in crown_dibs:
				crown_dibs.append(body)
				
func _on_body_exited(body: Node) -> void:
	if body is CharacterBody2D:
		if following != body:
			if body in crown_dibs:
				crown_dibs.erase(body)
		

func _process(delta):

	var vector_to_target: Vector2
	var original_vector_to_target: Vector2
	if following:
		vector_to_target = following.global_position - global_position + offset
		original_vector_to_target = vector_to_target - offset
		var vector_angle: float = vector_to_target.angle()
		vector_to_target = Vector2(cos(vector_angle), sin(vector_angle)) * (vector_to_target.length())
		linear_velocity = vector_to_target * speed * delta

		score_duration -= delta
		if score_duration <= 0:
			score_duration = 1
			game_root.crown_scored(following.player_id)

	else:
		if follow_line.points.size() > 0:
			follow_line.rotation += idle_angle_speed * delta
			var target_position: Vector2 = follow_line.to_global(follow_line.points[current_point])
			vector_to_target = target_position - global_position
			original_vector_to_target = vector_to_target
			linear_velocity = vector_to_target.normalized() * idle_speed

			
			if vector_to_target.length() < close_distance:
				current_point = (current_point + 1) % follow_line.points.size()

	var target_angle: float = original_vector_to_target.angle() + deg_to_rad(angle_offset)
	var using_angle_difference: float = wrapf(target_angle - rotation, -PI, PI)
	angular_velocity = clamp(using_angle_difference * angular_speed, -angular_speed, angular_speed)
		
func _disconnect():
	if crown_dibs.size() > 0:
		following = crown_dibs[0]
		crown_dibs.erase(following)
		following.tree_exiting.connect(_disconnect)
	else:
		follow_line.position = global_position
		
