extends Node3D
class_name Weapon

#
# Base class for all weapons.
# A weapon owns its whole attack: it locks the wielder's movement, plays the
# attack animation on the wielder's sprite, and unlocks when the animation ends.
# Controllers only call setup() once and attack() when they want to attack.
#
# Subclasses override:
#   get_attack_animation_name()  -> name of the wielder's attack animation
#   _on_attack_start()           -> e.g. enable hitbox, spawn projectile
#   _on_attack_end()             -> e.g. disable hitbox
#   flip(dir)                    -> mirror the weapon to the facing direction
#   reload()
#

signal attack_started
signal attack_finished

@export var damage: int = 1
@export var cooldown: float = 0.0

var wielder: Movable
var sprite: AnimatedSprite3D
var is_attacking := false
var _cooldown_timer := 0.0

func setup(new_wielder: Movable, new_sprite: AnimatedSprite3D) -> void:
	wielder = new_wielder
	sprite = new_sprite
	sprite.animation_finished.connect(_on_animation_finished)

func can_attack() -> bool:
	return wielder != null and not is_attacking and _cooldown_timer <= 0.0 and not wielder.is_rolling

## Starts an attack. Returns true if the attack actually started.
func attack() -> bool:
	if not can_attack():
		return false
	is_attacking = true
	_cooldown_timer = cooldown
	wielder.movement_locked = true
	wielder.velocity.x = 0.0
	sprite.play(get_attack_animation_name())
	_on_attack_start()
	attack_started.emit()
	return true

## The group this weapon hurts: whichever of "player"/"enemy" the wielder is not in.
func get_target_group() -> StringName:
	return &"enemy" if wielder.is_in_group(&"player") else &"player"

func cancel_attack() -> void:
	if is_attacking:
		_end_attack()

func _physics_process(delta: float) -> void:
	if wielder == null:
		return
	_cooldown_timer -= delta
	flip(wielder.facing)

func _on_animation_finished() -> void:
	if is_attacking and sprite.animation == get_attack_animation_name():
		_end_attack()

func _end_attack() -> void:
	is_attacking = false
	_on_attack_end()
	wielder.movement_locked = false
	attack_finished.emit()

# --- overridable -------------------------------------------------------------

func get_attack_animation_name() -> String:
	push_warning("Weapon.get_attack_animation_name not implemented")
	return ""

func _on_attack_start() -> void:
	pass

func _on_attack_end() -> void:
	pass

func reload() -> void:
	pass

func flip(_dir: float) -> void:
	pass
