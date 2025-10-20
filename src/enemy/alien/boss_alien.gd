extends BossEnemy
class_name BossAlien

## Boss alien escalável automaticamente

func _ready() -> void:
	super._ready()
	
	# Stats base do boss
	base_health = 200.0
	base_damage = 30.0
	speed = 100.0
	xp_reward = 100
	attack_cooldown = 1.5
	attack_range = 40.0
	
	# Multiplicadores de boss
	boss_health_multiplier = 5.0
	boss_damage_multiplier = 2.5
	boss_size_multiplier = 2.5
	boss_speed_multiplier = 0.7
	boss_xp_multiplier = 5.0
	
	# Cor de partícula de morte
	death_particle_color = Color.PURPLE

func _attack(player_node: Node) -> void:
	if stunned or not can_attack:
		return
	
	can_attack = false
	_timer_attack_reset()
	
	# Boss causa dano em área
	if player_node.has_method("take_damage"):
		player_node.take_damage(damage)
		
		# Efeito visual de ataque do boss (explosão maior)
		VFXManager.spawn_explosion(global_position, scale.x * 0.5)

func get_attack_range() -> float:
	return attack_range
