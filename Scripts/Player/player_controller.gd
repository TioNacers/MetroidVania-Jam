extends Movable

@onready var sprite: AnimatedSprite3D = $AnimatedSprite3D

@export var primary_weapon_preload: PackedScene
@export var secondary_weapon_preload: PackedScene
@export var hp: int = 5

var primary_weapon: Weapon
var secondary_weapon: Weapon

func _ready() -> void:
	super()
	if primary_weapon_preload != null:
		equip_weapon(primary_weapon_preload, true)
	if secondary_weapon_preload != null:
		equip_weapon(secondary_weapon_preload, false)
	sprite.animation_finished.connect(_on_animation_finished)

func _physics_process(delta: float) -> void:
	# 1. Input -> intent (before the move)
	move_x(Input.get_axis("left", "right"), delta)

	if movement_locked:
		velocity.x = 0.0
	elif not is_rolling:
		if Input.is_action_just_pressed("jump"):
			jump()
		if Input.is_action_just_pressed("roll"):
			roll()
			if is_rolling:
				sprite.play("Roll_fast")
		elif Input.is_action_just_pressed("shoot") and primary_weapon != null:
			primary_weapon.attack()
		elif Input.is_action_just_pressed("punch") and secondary_weapon != null:
			secondary_weapon.attack()

	# 2. Gravity, run state and move_and_slide() happen once, in Movable
	super(delta)

	# 3. Animation uses the post-move state
	_update_animation()

func equip_weapon(scene: PackedScene, primary: bool) -> void:
	var old := primary_weapon if primary else secondary_weapon
	if old != null:
		old.cancel_attack()
		old.queue_free()

	var weapon: Weapon = scene.instantiate()
	add_child(weapon)
	weapon.setup(self, sprite)

	if primary:
		primary_weapon = weapon
	else:
		secondary_weapon = weapon

func take_damage(amount: int, _source: Node3D = null) -> void:
	if hp <= 0:
		return
	hp -= amount
	if hp <= 0:
		die()

func die() -> void:
	queue_free()

func _on_animation_finished() -> void:
	if sprite.animation == "Roll_fast":
		stop_rolling()

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
