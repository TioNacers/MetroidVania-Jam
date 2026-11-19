extends CharacterBody3D
class_name Movable

@export var movement_settings: MovementResource

var input_dir := 0.0
var facing := 1.0                 # last non-zero input direction
var is_running := false
var is_rolling := false
var movement_locked := false      # set by the controller (attacks, etc.)

var move_timer := 0.0
var air_timer := 0.0
var stop_timer := 0.0

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	assert(movement_settings != null, "%s has no movement_settings assigned" % name)

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	update_run_state(delta)

	if is_rolling and is_on_floor():
		velocity.x = facing * movement_settings.roll_speed

	velocity.z = 0.0
	move_and_slide()

func is_busy() -> bool:
	return is_rolling or movement_locked

func current_speed() -> float:
	return movement_settings.run_speed if is_running else movement_settings.walk_speed

func apply_gravity(delta: float) -> void:
	if not is_on_floor() and not movement_settings.flying:
		velocity.y -= gravity * delta

func update_run_state(delta: float) -> void:
	if is_busy():
		return
	if input_dir != 0.0:
		stop_timer = 0.0
		if is_on_floor():
			air_timer = 0.0
			move_timer += delta
			if move_timer >= movement_settings.time_to_run and movement_settings.can_run:
				is_running = true
		elif is_running:
			air_timer += delta
			if air_timer >= movement_settings.max_air_run_time:
				reset_run_state()
	else:
		stop_timer += delta
		if stop_timer >= movement_settings.turn_grace_time:
			reset_run_state()

func reset_run_state() -> void:
	move_timer = 0.0
	air_timer = 0.0
	stop_timer = 0.0
	is_running = false

func move_x(dir: float, delta: float) -> void:
	input_dir = dir                      # always track, even while busy
	if is_busy():
		return
	if dir != 0.0:
		facing = dir
		velocity.x = move_toward(velocity.x, dir * current_speed(),movement_settings.deceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, movement_settings.deceleration * delta)

func move_y(dir: float, delta: float) -> void:
	if is_busy() or not movement_settings.flying:
		return
	velocity.y = move_toward(velocity.y, dir * current_speed(), movement_settings.acceleration * delta)

func jump() -> void:
	if is_busy() or not movement_settings.can_jump or not is_on_floor():
		return
	velocity.y = movement_settings.jump_velocity

func roll() -> void:
	if is_busy() or not movement_settings.can_roll or not is_on_floor():
		return
	is_rolling = true

func stop_rolling() -> void:
	if not is_rolling:
		return
	is_rolling = false
	if input_dir == 0.0:      # no key held: stop dead instead of drifting
		velocity.x = 0.0
		reset_run_state()
