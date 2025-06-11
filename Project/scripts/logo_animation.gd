# logo_animation.gd
extends TextureRect

@export var rot_amplitude: float = 2.0
@export var rot_frequency: float = 4.0
@export var rot_offset: float = 0.5

@export var bob_amplitude: float = 30.0
@export var bob_frequency: float = 4.0
@export var bob_offset: float = 0.0

var time: float = 0.0	

func _process(delta: float) -> void:
	time += delta
	rotation_degrees = rot_amplitude * sin((time / rot_frequency) * TAU + rot_offset)
	position.y = (bob_amplitude * sin((time / bob_frequency) * TAU + bob_offset)) + bob_amplitude / 2
	

