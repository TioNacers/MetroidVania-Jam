extends Movable

@onready var sprite: AnimatedSprite3D = $AnimatedSprite3D

func _ready() -> void:
	super()
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
		elif Input.is_action_just_pressed("shoot"):
			_start_attack("Shoot_pistol")
		elif Input.is_action_just_pressed("punch"):
			_start_attack("Punch_jab")

	# 2. Gravity, run state and move_and_slide() happen once, in Movable
	super(delta)

	# 3. Animation uses the post-move state
	_update_animation()

func _start_attack(anim_name: String) -> void:
	movement_locked = true
	#TODO Trigger attack here
	velocity.x = 0.0
	sprite.play(anim_name)

func _on_animation_finished() -> void:
	match sprite.animation:
		"Roll_fast":
			stop_rolling()
		"Shoot_pistol", "Punch_jab":
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
