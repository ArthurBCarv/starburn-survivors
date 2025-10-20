extends Node
class_name UpgradeManager

const UpgradeBuilder = preload("res://src/upgrades/builder/builder_upgrade.gd")

@onready var player = get_parent()

var active_abilities: Dictionary = {}

var levels := {
	"fire_core": 0, 
	"fire_explosion": 0, 
	"fire_intensity": 0, 
	"fire_capstone": 0,
	"lightning_core": 0, 
	"lightning_thunder": 0, 
	"lightning_overload": 0, 
	"lightning_capstone": 0,
}

var max_levels := {
	"fire_core": 1, 
	"fire_explosion": 3, 
	"fire_intensity": 3, 
	"fire_capstone": 1,
	"lightning_core": 1, 
	"lightning_thunder": 3, 
	"lightning_overload": 3, 
	"lightning_capstone": 1,
}

const ABILITIES := {
	"fire_burn": preload("res://src/upgrades/abilities/fire_burn_ability.gd"),
	"fire_explosion": preload("res://src/upgrades/abilities/fire_explosion_ability.gd"),
	"chain_lightning": preload("res://src/upgrades/abilities/chain_lightning_ability.gd"),
	"thunder_strike": preload("res://src/upgrades/abilities/thunder_strike_ability.gd"),
	"overload": preload("res://src/upgrades/abilities/overload_ability.gd"),
}

signal upgrade_applied(id: String, level: int)


func _ready():
	print("[UpgradeManager] Inicializado")


func get_level(id: String) -> int: 
	return levels.get(id, 0)


func can_level(id: String) -> bool: 
	return get_level(id) < max_levels.get(id, 1)


func _prereq_met(id: String) -> bool:
	match id:
		"fire_core": 
			return true
		"fire_explosion", "fire_intensity": 
			return get_level("fire_core") >= 1
		"fire_capstone": 
			return get_level("fire_core") >= 1 and (get_level("fire_explosion") >= 3 or get_level("fire_intensity") >= 3)
		"lightning_core": 
			return true
		"lightning_thunder", "lightning_overload": 
			return get_level("lightning_core") >= 1
		"lightning_capstone": 
			return get_level("lightning_core") >= 1 and (get_level("lightning_thunder") >= 3 or get_level("lightning_overload") >= 3)
		_: 
			return false


func get_available_options(max_count := 3) -> Array[String]:
	var candidates: Array[String] = []
	
	for id in levels.keys():
		if can_level(id) and _prereq_met(id):
			candidates.append(id)
	
	candidates.shuffle()
	
	if candidates.size() > max_count:
		candidates.resize(max_count)
	
	print("[UpgradeManager] Opções disponíveis: %s" % str(candidates))
	return candidates


func apply_upgrade(id: String) -> void:
	if not can_level(id) or not _prereq_met(id): 
		print("[UpgradeManager] Não pode aplicar upgrade: %s" % id)
		return
	
	levels[id] += 1
	var lvl = levels[id]

	print("[UpgradeManager] Aplicando upgrade: %s (nível %d)" % [id, lvl])

	_apply_effects(id, lvl)
	# Se _apply_effects instanciou abilities e as colocou em active_abilities,
	# garanta que elas sejam adicionadas à cena como filhas do player.
	if player:
		for key in active_abilities.keys():
			var ability = active_abilities[key]
			# Se já for um Node e não estiver na árvore de cena, anexe ao player
			if ability is Node and ability.get_parent() == null:
				player.add_child(ability)
				# Tente passar o nível da habilidade, se suportado
				if ability.has_method("set_level"):
					ability.set_level(levels.get(key, 1))
				elif ability.has_method("init_level"):
					ability.init_level(levels.get(key, 1))
				# Ative a habilidade se houver um método de ativação
				if ability.has_method("activate"):
					ability.activate()
				print("[UpgradeManager] Habilidade %s adicionada ao player" % key)

	emit_signal("upgrade_applied", id, lvl)


func enable_ability(name: String, level: int) -> void:
	if not active_abilities.has(name):
		var ability_script = ABILITIES.get(name)
		if not ability_script:
			push_error("[UpgradeManager] Habilidade não encontrada: %s" % name)
			return
		
		var a: Node = ability_script.new()
		player.add_child(a)
		active_abilities[name] = a
		print("[UpgradeManager] Habilidade ativada: %s" % name)
	
	if active_abilities[name].has_method("set_level"):
		active_abilities[name].set_level(level)


func _apply_effects(id: String, level: int) -> void:
	match id:
		"fire_core":
			enable_ability("fire_burn", 1)
			var b := UpgradeBuilder.new()
			b.add_range(-20.0)
			player.apply_upgrade(b.build())
			
		"fire_explosion":
			enable_ability("fire_explosion", level)
			
		"fire_intensity":
			enable_ability("fire_burn", 1 + level)
			var b2 := UpgradeBuilder.new()
			b2.add_damage(3.0 if level == 3 else 2.0)
			b2.add_range(-5.0)
			player.apply_upgrade(b2.build())
			
		"fire_capstone":
			if active_abilities.has("fire_explosion"):
				active_abilities["fire_explosion"].set("apply_burn_on_aoe", true)

		"lightning_core":
			enable_ability("chain_lightning", 1)
			var b3 := UpgradeBuilder.new()
			b3.add_fire_rate(0.05)
			player.apply_upgrade(b3.build())
			
		"lightning_thunder":
			enable_ability("thunder_strike", level)
			
		"lightning_overload":
			enable_ability("overload", level)
			if level >= 2:
				var b4 := UpgradeBuilder.new()
				b4.add_fire_rate(0.02)
				player.apply_upgrade(b4.build())
				
		"lightning_capstone":
			if active_abilities.has("chain_lightning"):
				var cl = active_abilities["chain_lightning"]
				if cl.has_method("add_extra_bounce"): 
					cl.add_extra_bounce(1)
				else: 
					cl.set_level(cl.get("level") + 1)
			
			if active_abilities.has("thunder_strike"):
				var ts = active_abilities["thunder_strike"]
				ts.set("bonus_chance", ts.get("bonus_chance") + 0.02)
