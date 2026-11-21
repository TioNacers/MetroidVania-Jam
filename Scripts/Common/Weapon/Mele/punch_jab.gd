extends Weapon

const RANGED: bool = false
const NAME: String = "PunchJab"

@onready var hitbox: Area3D = $Area3D
@onready var collision_shape_3d: CollisionShape3D = $Area3D/CollisionShape3D
@onready var x_pos: float = collision_shape_3d.position.x

var _already_hit: Array[Node3D] = []

func _ready() -> void:
	hitbox.monitoring = false
	hitbox.body_entered.connect(_on_body_entered)

func get_attack_animation_name() -> String:
	return NAME + "_attack"

func _on_attack_start() -> void:
	_already_hit.clear()
	hitbox.set_deferred("monitoring", true)

func _on_attack_end() -> void:
	hitbox.set_deferred("monitoring", false)

func _on_body_entered(body: Node3D) -> void:
	if body == wielder or body in _already_hit or not body.is_in_group(get_target_group()):
		return
	_already_hit.append(body)
	if body.has_method("take_damage"):
		body.take_damage(damage, wielder)

func flip(dir: float) -> void:
	collision_shape_3d.position.x = -x_pos if dir < 0.0 else x_pos
