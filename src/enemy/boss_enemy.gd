extends EnemyBase
class_name BossEnemy

## Boss escalável automaticamente baseado na wave

@export var boss_health_multiplier := 5.0
@export var boss_damage_multiplier := 2.0
@export var boss_size_multiplier := 2.5
@export var boss_speed_multiplier := 0.7  # Bosses são mais lentos
@export var boss_xp_multiplier := 5.0

var original_scale := Vector2.ONE

func _ready() -> void:
	super._ready()
	original_scale = scale
	add_to_group("boss")
	
	# Cor de partícula diferente para boss
	death_particle_color = Color.PURPLE

func scale_with_wave(wave: int) -> void:
	_current_wave = wave
	
	# Multiplica stats base por multiplicadores de boss
	var health_multiplier := 1.2
	var damage_multiplier := 1.1
	
	base_health *= boss_health_multiplier
	base_damage *= boss_damage_multiplier
	speed *= boss_speed_multiplier
	xp_reward = int(xp_reward * boss_xp_multiplier)
	
	# Aplica escala de wave
	health = base_health * pow(health_multiplier, max(0, wave - 1))
	damage = base_damage * pow(damage_multiplier, max(0, wave - 1))
	
	# Escala visual baseada na wave
	var wave_scale_bonus = 1.0 + (wave - 1) * 0.1  # +10% por wave
	var final_scale = boss_size_multiplier * wave_scale_bonus
	scale = original_scale * final_scale
	
	# Atualiza o damage component
	if damage_component:
		damage_component.max_health = health
		damage_component.current_health = health
	
	print("[Boss] Escalado para wave %d - HP: %.0f, Dano: %.0f, Escala: %.2f" % [wave, health, damage, final_scale])

func _attack(player_node: Node) -> void:
	if not can_attack:
		return
	
	can_attack = false
	_timer_attack_reset()
	
	# Boss causa dano em área
	if player_node.has_method("take_damage"):
		player_node.take_damage(damage)
		
		# Efeito visual de ataque
		VFXManager.spawn_explosion(global_position, scale.x * 0.5)
