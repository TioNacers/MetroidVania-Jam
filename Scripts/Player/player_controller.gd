extends Movable

@onready var sprite: AnimatedSprite3D = $AnimatedSprite3D

@export var primary_weapon: Weapon
@export var secondary_weapon: Weapon
var weapon_attack_names: Array[String]

func _ready() -> void:
	super()
	weapon_attack_names.append(primary_weapon.get_attack_animation_name())
	weapon_attack_names.append(secondary_weapon.get_attack_animation_name())
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
			_start_attack(primary_weapon.get_attack_animation_name())
		elif Input.is_action_just_pressed("punch") and secondary_weapon != null:
			secondary_weapon.attack()
			_start_attack(secondary_weapon.get_attack_animation_name())

	# 2. Gravity, run state and move_and_slide() happen once, in Movable
	super(delta)

	# 3. Animation uses the post-move state
	_update_animation()

func equip_weapon(weapon: Weapon, primary: bool):
	if primary:
		weapon_attack_names.erase(primary_weapon.get_attack_animation_name())
		primary_weapon = weapon
		weapon_attack_names.append(weapon.get_attack_animation_name())
	else :
		weapon_attack_names.erase(secondary_weapon.get_attack_animation_name())
		secondary_weapon = weapon
		weapon_attack_names.append(weapon.get_attack_animation_name())


func _start_attack(anim_name: String) -> void:
	movement_locked = true
	velocity.x = 0.0
	sprite.play(anim_name)

func _on_animation_finished() -> void:

	if (sprite.animation == "Roll_fast"):
		stop_rolling()
	elif weapon_attack_names.has(sprite.animation):
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
