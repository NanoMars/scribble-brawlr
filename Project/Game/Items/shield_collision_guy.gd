extends StaticBody2D

var _shield: Node = null

var shield: Node:
	set(value):
		_shield = value
		if _shield:
			holder = _shield.holder
			player_id = holder.player_id
			velocity = holder.velocity
var holder: Node = null
var player_id: int = -1
var kill_velocity_threshold: float = 350
var other_kill_velocity_threshold: float = 30.0
var velocity: Vector2 = Vector2.ZERO

@onready var area: Area2D = $Area2D

func kill(direction: Vector2, attribution) -> void:
	if _shield:
		_shield.kill(direction, attribution)

func _ready() -> void:
	area.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if holder == null or not is_instance_valid(holder):
		return
	
	velocity = holder.velocity
	var other_velocity = body.get_linear_velocity() if body.has_method("get_linear_velocity") else Vector2.ZERO
	var relative_velocity = (_shield.linear_velocity - other_velocity).length()
	print("_shield Collision Guy: Body Entered", body.name, " with relative velocity: ", relative_velocity)
	var other_meta = body.get_meta("kill_owner") if body.has_meta("kill_owner") else null
	var other_harmless = true if get_tree().get_nodes_in_group("harmless").has(body) else false
	var other_damaging = true if get_tree().get_nodes_in_group("damaging").has(body) else false
	if ((relative_velocity >= kill_velocity_threshold and other_meta != player_id) and not other_harmless) or ((other_velocity.length() >= other_kill_velocity_threshold and other_meta != player_id) and not other_harmless) or (other_damaging and not other_harmless):
		await get_tree().process_frame
		kill(velocity - other_velocity, body)
