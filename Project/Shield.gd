# shield.gd
extends Item


@export var durability: int = 3
var initial_durability: int = durability
@export var shield_collision_guy: PackedScene
@onready var remote_transform: RemoteTransform2D = $RemoteTransform2D

var shield_collision_instance: Node2D = null

func _ready() -> void:
	super._ready()
	
	

func _process(delta: float) -> void:
	super._process(delta)
	if is_instance_valid(shield_collision_instance) and shield_collision_instance:
		shield_collision_instance.global_position = global_position
		shield_collision_instance.global_rotation = global_rotation
		
	

func update_state():
	super.update_state()
	if is_held:
		holder.ammo_progress = (float(durability) / float(initial_durability)) * 100	
		shield_collision_instance = shield_collision_guy.instantiate()
		get_tree().get_root().add_child(shield_collision_instance)
		shield_collision_instance.global_position = global_position
		shield_collision_instance.global_rotation = global_rotation
		shield_collision_instance.set_meta("kill_owner", holder_player_id)
		shield_collision_instance.shield = self
	elif not is_held:
		if is_instance_valid(shield_collision_instance) and shield_collision_instance:
			shield_collision_instance.queue_free()
			shield_collision_instance = null
	
func kill(direction: Vector2, _attribution) -> void:
	durability -= 1
	if durability > 0:
		holder.ammo_progress = (float(durability) / float(initial_durability)) * 100	
		if holder:
			holder.ammo_progress = (float(durability) / float(initial_durability)) * 100
			holder.velocity -= direction * 0.1
	else:
		despawn()
		
	
