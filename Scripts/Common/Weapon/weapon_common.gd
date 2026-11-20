extends Resource
class_name Weapon



@export var weapon_config: WeaponResource

func get_attack_animation_name() -> String:
	return weapon_config.weapon_name + "_attack"

#
# common class for all attacks
# this is just an interface
# all functions below this comment will get overwritten
#
func attack():pass

func reload():pass
