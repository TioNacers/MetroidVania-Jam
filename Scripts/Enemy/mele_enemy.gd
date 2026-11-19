extends Movable

@export var attack_range := 1.5
@export var attack_cooldown := 1.0
@export var jump_cooldown := 0.6

@onready var sprite: AnimatedSprite3D = $AnimatedSprite3D

var target: Node3D
var attack_timer := 0.0
var jump_timer := 0.0

func _ready() -> void:
	super()
	sprite.animation_finished.connect(_on_animation_finished)

func _physics_process(delta: float) -> void:
	attack_timer -= delta
	jump_timer -= delta
	target = _find_nearest_player()

	var dir := 0.0
	if target:
		var dx := target.global_position.x - global_position.x
		var dy := target.global_position.y - global_position.y
		dir = signf(dx) if absf(dx) > 0.1 else 0.0

		if absf(dx) <= attack_range and absf(dy) <= attack_range:
			dir = 0.0
			if not is_busy():
				facing = signf(dx) if dx != 0.0 else facing
				if attack_timer <= 0.0:
					attack_timer = attack_cooldown
					movement_locked = true
					velocity.x = 0.0
					sprite.play("Punch_jab")
		elif is_on_wall() and is_on_floor() and jump_timer <= 0.0:
			jump()
			jump_timer = jump_cooldown

	move_x(dir, delta)
	if movement_locked:
		velocity.x = 0.0

	super(delta)
	_update_animation()

func _find_nearest_player() -> Node3D:
	var best: Node3D = null
	var best_dist := INF
	for n in get_tree().get_nodes_in_group("player"):
		var d := global_position.distance_squared_to(n.global_position)
		if d < best_dist:
			best_dist = d
			best = n
	return best

func _on_animation_finished() -> void:
	if sprite.animation == "Punch_jab":
		movement_locked = false

func _update_animation() -> void:
	sprite.flip_h = facing < 0.0
	if is_busy():
		return
	if not is_on_floor():
		sprite.play("Jump")
	elif input_dir != 0.0 and absf(velocity.x) > 0.1:
		sprite.play("Run" if is_running else "Walk")
	else:
		sprite.play("Idle")
