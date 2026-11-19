extends Node3D

@export var follow_speed: float = 6.0
@export var look_ahead_distance: float = 1.5
@export var vertical_offset: float = 0.5

@onready var player: CharacterBody3D = get_parent()

func _ready() -> void:
	# Desvincula el movimiento rígido respecto al Player
	top_level = true
	global_position = player.global_position

func _physics_process(delta: float) -> void:
	if not is_instance_valid(player):
		return

	# Calcula un pequeño adelanto hacia donde mira el personaje
	var sprite: AnimatedSprite3D = player.get_node("AnimatedSprite3D")
	var look_dir: float = -1.0 if sprite.flip_h else 1.0
	var target_x: float = player.global_position.x + (look_dir * look_ahead_distance)
	var target_y: float = player.global_position.y + vertical_offset

	var target_pos := Vector3(target_x, target_y, player.global_position.z)

	# Interpolación exponencial suave independiente de los FPS
	global_position = global_position.lerp(target_pos, 1.0 - exp(-follow_speed * delta))
