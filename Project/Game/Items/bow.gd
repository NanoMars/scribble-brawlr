# bow.gd
extends Item

@export var empty_texture: Texture
@export var animation_textures: Array[Texture] = []
@export var animation_curve: Curve
@export var animation_duration: float = 1.0

var button_held: bool = false
var progress: float = 0.0

@export var ammo: int = 3
@onready var initial_ammo = ammo
@export var projectile_scene: PackedScene
@export var projectile_speed: float = 300.0

func press(obstacle_distance: float):
	#$CPUParticles2D.emitting = true
	button_held = true

func release(obstacle_distance: float):
	button_held = false
	if progress >= 1.0 and ammo > 0 and obstacle_distance == -1:
		var projectile: Node2D = projectile_scene.instantiate()
		get_tree().get_root().add_child(projectile)
		projectile.global_position = global_position
		projectile.rotation = global_rotation
		projectile.set_meta("kill_owner", holder_player_id)
		projectile.apply_impulse(Vector2(cos(global_rotation), sin(global_rotation)) * projectile_speed)
		ammo -= 1
		progress = 0.0
		holder.ammo_progress = (float(ammo) / float(initial_ammo)) * 100
		if ammo <= 0:
			depleted = true
			

func _process(delta: float) -> void:
	super._process(delta)
	if ammo <= 0:
		$Sprite2D.texture = empty_texture
		return
	if button_held:
		progress = min(progress + delta / animation_duration, 1.0)
	else:
		progress = max(progress - delta / animation_duration, 0.0)

	var animation_progress: float = max(min(animation_curve.sample(progress), 1.0), 0.0)
	$Sprite2D.texture = animation_textures[int(animation_progress * (animation_textures.size() - 1))]

func update_state():
	super.update_state()
	if is_held:
		holder.ammo_progress = (float(ammo) / float(initial_ammo)) * 100