extends Node
class_name PlayerStats

# Stats base
var base_damage: float = 10.0
var base_fire_rate: float = 0.15
var base_speed: float = 600.0
var base_max_hp: float = 100.0
var base_detection_range: float = 250.0

# Multiplicadores acumulados
var damage_mult: float = 1.0
var fire_rate_mult: float = 1.0
var speed_mult: float = 1.0
var xp_mult: float = 1.0

# Stats flat
var flat_damage: float = 0.0
var flat_fire_rate: float = 0.0
var flat_speed: float = 0.0
var flat_max_hp: float = 0.0
var flat_armor: float = 0.0
var flat_detection_range: float = 0.0

# Contadores
var projectile_count: int = 1
var pierce_count: int = 0
var chain_count: int = 0

# Chances
var crit_chance: float = 0.0
var crit_mult: float = 2.0
var dodge_chance: float = 0.0
var explosion_chance: float = 0.0

# Flags booleanas
var has_homing: bool = false
var has_infinite_pierce: bool = false
var has_burn: bool = false
var has_chain_lightning: bool = false
var has_shield: bool = false
var has_dash: bool = false
var has_teleport: bool = false

# Stats de defesa
var damage_reduction: float = 0.0
var thorns: float = 0.0
var hp_regen: float = 0.0
var shield_max_hp: float = 0.0
var shield_recharge_time: float = 5.0

# Stats de efeitos
var burn_damage: float = 5.0
var burn_duration: float = 3.0
var burn_spread: bool = false
var burn_death_explosion: bool = false

var explosion_radius: float = 80.0
var explosion_damage_mult: float = 0.5

var chain_range: float = 150.0
var slow_amount: float = 0.0
var slow_duration: float = 0.0
var stun_chance: float = 0.0

# Stats de projétil
var projectile_scale: float = 1.0
var pierce_damage_stack: float = 0.0

# Stats de mísseis
var missile_enabled: bool = false
var missile_every_n: int = 3
var missile_damage_mult: float = 1.5
var missile_count: int = 1
var missile_cluster: bool = false

# Stats de drones
var drone_count: int = 0
var drone_damage_mult: float = 1.0
var drone_fire_rate_mult: float = 1.0
var drone_block: bool = false

# Stats de habilidades especiais
var pickup_range_mult: float = 1.0
var orbital_enabled: bool = false
var orbital_cooldown: float = 15.0
var orbital_damage: float = 500.0
var blackhole_enabled: bool = false
var blackhole_cooldown: float = 20.0
var blackhole_damage: float = 100.0
var time_slow_chance: float = 0.0
var dash_cooldown: float = 3.0
var teleport_cooldown: float = 8.0

# Beam laser
var continuous_beam: bool = false


# Getters calculados
func get_damage() -> float:
	return (base_damage + flat_damage) * damage_mult

func get_fire_rate() -> float:
	return max(0.01, (base_fire_rate + flat_fire_rate) * fire_rate_mult)

func get_speed() -> float:
	return (base_speed + flat_speed) * speed_mult

func get_max_hp() -> float:
	return base_max_hp + flat_max_hp

func get_detection_range() -> float:
	return base_detection_range + flat_detection_range

func get_pickup_range() -> float:
	return 100.0 * pickup_range_mult


# Aplica modificadores de upgrade
func apply_modifier(key: String, value: Variant) -> void:
	match key:
		# Multiplicadores
		"damage_mult": damage_mult += value
		"fire_rate_mult": fire_rate_mult += value
		"speed_mult": speed_mult += value
		"xp_mult": xp_mult += value
		
		# Flat stats
		"flat_damage": flat_damage += value
		"flat_fire_rate": flat_fire_rate += value
		"flat_speed": flat_speed += value
		"max_hp": flat_max_hp += value
		"flat_armor": flat_armor += value
		"detection_range": flat_detection_range += value
		
		# Contadores
		"projectile_count": projectile_count += value
		"pierce": pierce_count += value
		"chain_count": chain_count += value
		
		# Chances
		"crit_chance": crit_chance += value
		"crit_mult": crit_mult += value
		"dodge_chance": dodge_chance += value
		"explosion_chance": explosion_chance += value
		
		# Flags
		"homing": has_homing = value
		"infinite_pierce": has_infinite_pierce = value
		"enable_burn": has_burn = value
		"chain_lightning": 
			has_chain_lightning = true
			chain_count = value
		"dash": has_dash = value
		"teleport": has_teleport = value
		
		# Defesa
		"damage_reduction": damage_reduction += value
		"thorns": thorns += value
		"hp_regen": hp_regen += value
		"shield_hp": 
			has_shield = true
			shield_max_hp += value
		"shield_recharge": shield_recharge_time += value
		
		# Burn
		"burn_damage": burn_damage += value
		"burn_duration": burn_duration += value
		"burn_spread": burn_spread = value
		"burn_death_explosion": burn_death_explosion = value
		
		# Explosão
		"explosion_radius": explosion_radius += value
		
		# Chain/Electric
		"chain_range": chain_range = value
		"slow_amount": slow_amount += value
		"slow_duration": slow_duration += value
		"stun_chance": stun_chance += value
		
		# Projétil
		"projectile_scale": projectile_scale += value
		"pierce_damage_stack": pierce_damage_stack += value
		
		# Mísseis
		"missile_every_n": 
			missile_enabled = true
			missile_every_n = max(1, int(missile_every_n + value))
		"missile_damage": missile_damage_mult += value
		"missile_count": missile_count += value
		"missile_cluster": missile_cluster = value
		
		# Drones
		"drone_count": drone_count += value
		"drone_damage": drone_damage_mult += value
		"drone_fire_rate": drone_fire_rate_mult += value
		"drone_block": drone_block = value
		
		# Especiais
		"pickup_range": pickup_range_mult += value
		"orbital_cooldown": 
			orbital_enabled = true
			orbital_cooldown += value
		"orbital_damage": orbital_damage += value
		"blackhole_cooldown": 
			blackhole_enabled = true
			blackhole_cooldown += value
		"blackhole_damage": blackhole_damage += value
		"time_slow_chance": time_slow_chance += value
		"dash_cooldown": dash_cooldown += value
		"teleport_cooldown": teleport_cooldown += value
		
		# Beam
		"continuous_beam": continuous_beam = value
		
		_:
			push_warning("[PlayerStats] Modificador desconhecido: %s" % key)
	
	EventBus.player_stats_changed.emit()
