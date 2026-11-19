extends CharacterBody3D

@export var walk_speed: float = 4.0
@export var run_speed: float = 7.5
@export var time_to_run: float = 1.25
@export var max_air_run_time: float = 1.2
@export var turn_grace_time: float = 0.25
@export var deceleration: float = 35.0
@export var jump_velocity: float = 5
@export var roll_speed: float = 6.5

@onready var sprite: AnimatedSprite3D = $AnimatedSprite3D

enum State { NORMAL, ATTACK, ROLL }
var current_state: State = State.NORMAL
var roll_direction: float = 1.0

# Variables de impulso y carrera
var move_timer: float = 0.0
var air_timer: float = 0.0
var stop_timer: float = 0.0
var is_running: bool = false

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	sprite.animation_finished.connect(_on_animation_finished)

func _physics_process(delta: float) -> void:
	# Gravedad
	if not is_on_floor():
		velocity.y -= gravity * delta

	match current_state:
		State.NORMAL:
			_handle_normal_state(delta)
		State.ATTACK:
			# Se detiene para disparar/golpear, pero NO borra el estado de carrera
			velocity.x = 0.0
		State.ROLL:
			# Mantiene velocidad fija durante el roll
			velocity.x = roll_direction * roll_speed

	# Bloquea el eje Z para mantener el movimiento en un plano 2D
	velocity.z = 0.0

	move_and_slide()
	_update_animation()

func _handle_normal_state(delta: float) -> void:
	# Salto
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# Movimiento horizontal
	var input_dir: float = Input.get_axis("left", "right")
	
	if input_dir != 0.0:
		stop_timer = 0.0

		if is_on_floor():
			air_timer = 0.0
			move_timer += delta
			if move_timer >= time_to_run:
				is_running = true
		else:
			if is_running:
				air_timer += delta
				if air_timer >= max_air_run_time:
					_reset_run_state()

		var target_speed: float = (run_speed if is_running else walk_speed) * input_dir
		velocity.x = move_toward(velocity.x, target_speed, deceleration * delta * 2.5)
		sprite.flip_h = input_dir < 0.0
	else:
		# Si suelta teclas, espera el tiempo de gracia antes de perder la carrera
		stop_timer += delta
		if stop_timer >= turn_grace_time:
			_reset_run_state()
		
		# Frena al personaje rápidamente si no hay teclas presionadas
		velocity.x = move_toward(velocity.x, 0.0, deceleration * delta)

	# Voltereta (solo en el suelo)
	if Input.is_action_just_pressed("roll") and is_on_floor():
		_start_roll()
		return

	# Ataques
	if Input.is_action_just_pressed("shoot"):
		_start_attack("Shoot_pistol")
	elif Input.is_action_just_pressed("punch"):
		_start_attack("Punch_jab")

func _reset_run_state() -> void:
	move_timer = 0.0
	air_timer = 0.0
	stop_timer = 0.0
	is_running = false

func _start_roll() -> void:
	current_state = State.ROLL
	roll_direction = -1.0 if sprite.flip_h else 1.0
	sprite.play("Roll_fast")

func _start_attack(anim_name: String) -> void:
	current_state = State.ATTACK
	velocity.x = 0.0
	sprite.play(anim_name)

func _on_animation_finished() -> void:
	if sprite.animation == "Roll_fast":
		current_state = State.NORMAL
		# Al terminar el roll, si no estás presionando moverte, frena en seco para no caminar solo
		if Input.get_axis("left", "right") == 0.0:
			velocity.x = 0.0
			_reset_run_state()
		_update_animation()
		
	elif sprite.animation in ["Shoot_pistol", "Punch_jab"]:
		current_state = State.NORMAL
		# Si mantienes la tecla presionada al terminar el disparo, retoma la carrera de inmediato
		var input_dir: float = Input.get_axis("left", "right")
		if input_dir != 0.0:
			velocity.x = input_dir * (run_speed if is_running else walk_speed)
			sprite.flip_h = input_dir < 0.0
		_update_animation()

func _update_animation() -> void:
	if current_state != State.NORMAL:
		return

	if not is_on_floor():
		sprite.play("Jump")
	elif abs(velocity.x) > 0.1 and Input.get_axis("left", "right") != 0.0:
		if is_running:
			sprite.play("Run")
		else:
			sprite.play("Walk")
	else:
		sprite.play("Idle")
