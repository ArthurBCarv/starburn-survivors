extends Node

# Eventos de combate
signal enemy_spawned(enemy: Node)
signal enemy_died(enemy: Node, xp_amount: int)
signal boss_spawned(boss: Node)
signal boss_died(boss: Node, xp_amount: int)

# Eventos do player
signal player_health_changed(current: float, max_value: float)
signal player_shield_changed(current: float, max_value: float)
signal player_xp_changed(xp: int, xp_to_next: int, level: int)
signal player_leveled_up(new_level: int)
signal player_died()
signal player_stats_changed()

# Eventos de wave
signal wave_started(wave: int, is_boss: bool, enemy_count: int)
signal wave_cleared(wave: int)

# Eventos de upgrade
signal upgrade_applied(upgrade_id: String, level: int)

# Eventos de efeitos
signal effect_applied(target: Node, effect_type: String, data: Dictionary)
signal projectile_hit(projectile: Node, target: Node, damage: float)
