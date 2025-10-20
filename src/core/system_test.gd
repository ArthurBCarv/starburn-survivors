extends Node
class_name SystemTest

## Script de teste para verificar todos os sistemas implementados

func _ready() -> void:
	print("\n=== INICIANDO TESTES DE SISTEMA ===\n")
	
	test_autoloads()
	test_vfx_system()
	test_damage_component()
	test_boss_system()
	test_enemy_spawner()
	
	print("\n=== TESTES CONCLUÍDOS ===\n")

func test_autoloads() -> void:
	print("📋 Testando Autoloads...")
	
	# Testa EventBus
	if EventBus:
		print("  ✅ EventBus carregado")
	else:
		print("  ❌ EventBus não encontrado")
	
	# Testa ObjectPool
	if ObjectPool:
		print("  ✅ ObjectPool carregado")
	else:
		print("  ❌ ObjectPool não encontrado")
	
	# Testa VFXManager
	if VFXManager:
		print("  ✅ VFXManager carregado")
	else:
		print("  ❌ VFXManager não encontrado")
	
	print()

func test_vfx_system() -> void:
	print("✨ Testando Sistema de VFX...")
	
	# Testa se as cenas de partículas existem
	var effects = [
		"res://src/vfx/particles/muzzle_flash.tscn",
		"res://src/vfx/particles/hit_impact.tscn",
		"res://src/vfx/particles/explosion.tscn",
		"res://src/vfx/particles/enemy_death.tscn",
		"res://src/vfx/particles/plasma_trail.tscn"
	]
	
	for effect_path in effects:
		if ResourceLoader.exists(effect_path):
			print("  ✅ %s existe" % effect_path.get_file())
		else:
			print("  ❌ %s não encontrado" % effect_path.get_file())
	
	print()

func test_damage_component() -> void:
	print("💥 Testando DamageComponent...")
	
	var damage_comp = DamageComponent.new()
	damage_comp.max_health = 100
	damage_comp.current_health = 100
	
	# Testa dano
	damage_comp.take_damage(25)
	if damage_comp.current_health == 75:
		print("  ✅ Dano aplicado corretamente (75/100)")
	else:
		print("  ❌ Dano não aplicado corretamente")
	
	# Testa cura
	damage_comp.heal(10)
	if damage_comp.current_health == 85:
		print("  ✅ Cura aplicada corretamente (85/100)")
	else:
		print("  ❌ Cura não aplicada corretamente")
	
	# Testa morte
	var died = false
	damage_comp.died.connect(func(): died = true)
	damage_comp.take_damage(100)
	
	if died:
		print("  ✅ Sinal de morte emitido")
	else:
		print("  ❌ Sinal de morte não emitido")
	
	damage_comp.queue_free()
	print()

func test_boss_system() -> void:
	print("👹 Testando Sistema de Boss...")
	
	# Testa criação de boss
	var boss = BossEnemy.new()
	boss.base_health = 100
	boss.base_damage = 20
	boss.boss_health_multiplier = 5.0
	boss.boss_damage_multiplier = 2.0
	
	# Testa escalamento
	boss.scale_with_wave(3)
	
	if boss.health > 100:
		print("  ✅ Boss escalado corretamente (HP: %.0f)" % boss.health)
	else:
		print("  ❌ Boss não escalado corretamente")
	
	if boss.damage > 20:
		print("  ✅ Dano do boss escalado (Dano: %.0f)" % boss.damage)
	else:
		print("  ❌ Dano do boss não escalado")
	
	if boss.scale.x > 1.0:
		print("  ✅ Tamanho do boss escalado (Escala: %.2f)" % boss.scale.x)
	else:
		print("  ❌ Tamanho do boss não escalado")
	
	boss.queue_free()
	print()

func test_enemy_spawner() -> void:
	print("🎯 Testando EnemySpawner...")
	
	var spawner = EnemySpawner.new()
	
	# Verifica propriedades
	if spawner.has_method("_start_wave"):
		print("  ✅ Método _start_wave existe")
	else:
		print("  ❌ Método _start_wave não encontrado")
	
	if spawner.has_method("_spawn_enemy"):
		print("  ✅ Método _spawn_enemy existe")
	else:
		print("  ❌ Método _spawn_enemy não encontrado")
	
	if spawner.has_method("_is_boss_wave"):
		print("  ✅ Método _is_boss_wave existe")
	else:
		print("  ❌ Método _is_boss_wave não encontrado")
	
	# Testa lógica de boss wave
	spawner.boss_wave_interval = 5
	var is_boss_5 = spawner._is_boss_wave(5)
	var is_boss_10 = spawner._is_boss_wave(10)
	var is_boss_3 = spawner._is_boss_wave(3)
	
	if is_boss_5 and is_boss_10 and not is_boss_3:
		print("  ✅ Lógica de boss wave funcionando")
	else:
		print("  ❌ Lógica de boss wave com problemas")
	
	spawner.queue_free()
	print()
