extends EnemyBase
class_name Alien

## Inimigo alien básico com ataque corpo a corpo

func _ready() -> void:
	super._ready()
	
	# Stats base
	base_health = 30.0
	base_damage = 10.0
	speed = 100.0
	xp_reward = 10
	attack_cooldown = 1.0
	attack_range = 25.0
	
	# Cor de partícula de morte
	death_particle_color = Color(1.0, 0.3, 0.3)  # Vermelho

func _attack(player_node: Node) -> void:
	if stunned or not can_attack:
		return
	
	can_attack = false
	_timer_attack_reset()
	
	# Ataque corpo a corpo
	if player_node.has_method("take_damage"):
		player_node.take_damage(damage)
		
		# Efeito visual de ataque
		VFXManager.spawn_hit_impact(global_position)

func get_attack_range() -> float:
	return attack_range
