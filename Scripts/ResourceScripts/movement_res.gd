extends Resource
class_name MovementResource

@export var walk_speed: float = 4.0
@export var turn_grace_time: float = 0.25
@export var deceleration: float = 35.0

@export_category("Running")
@export var can_run: bool = true
@export var run_speed: float = 7.5
@export var time_to_run: float = 1.25
@export var max_air_run_time: float = 1.2

@export_category("Rolling")
@export var can_roll: bool = true
@export var roll_speed: float = 6.5
@export var roll_cooldown: float = 1

@export_category("Jumping")
@export var can_jump: bool = true
@export var jump_velocity: float = 5

@export_category("Flying")
@export var flying: bool = false
