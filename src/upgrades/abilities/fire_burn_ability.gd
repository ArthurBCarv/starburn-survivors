extends Node
class_name FireBurnAbility

var level := 1
var burn_dps := 2.0
var burn_duration := 2.0

func set_level(l: int) -> void:
	level = l
	burn_dps = 2.0 + (level - 1) * 1.0
	burn_duration = 2.0 + (level - 1) * 0.5

func on_projectile_hit(projectile, enemy) -> void:
	if not is_instance_valid(enemy): return
	var sec = enemy.get_node_or_null("StatusEffectComponent")
	if sec: sec.apply_burn(burn_dps, burn_duration)
