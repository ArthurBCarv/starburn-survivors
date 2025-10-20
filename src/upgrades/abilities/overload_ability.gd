extends Node
class_name OverloadAbility

var level := 1
var bonus_damage := 3.0

func set_level(l: int) -> void:
	level = l
	bonus_damage = 3.0 + (level - 1) * 2.0

func on_projectile_hit(projectile, enemy) -> void:
	if not is_instance_valid(enemy): return
	var sec = enemy.get_node_or_null("StatusEffectComponent")
	if sec and sec.is_stunned():
		if enemy.has_method("take_damage"):
			enemy.take_damage(bonus_damage)
