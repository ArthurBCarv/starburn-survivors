extends Node2D

## Cena de teste principal para verificar todos os sistemas

@onready var player: CharacterBody2D = $Player
@onready var enemy_spawner: EnemySpawner = $EnemySpawner
@onready var upgrade_ui: Control = $UI/UpgradeUI
@onready var hud: Control = $UI/HUD

# HUD elements
@onready var health_bar: ProgressBar = $UI/HUD/HealthBar
@onready var xp_bar: ProgressBar = $UI/HUD/XPBar
@onready var level_label: Label = $UI/HUD/LevelLabel
@onready var wave_label: Label = $UI/HUD/WaveLabel
@onready var enemies_label: Label = $UI/HUD/EnemiesLabel

func _ready() -> void:
	print("\n=== INICIANDO JOGO ===\n")
	
	# Configura player
	if player:
		print("✅ Player encontrado")
		if player.player_level:
			player.player_level.level_up.connect(_on_player_level_up)
			player.player_level.xp_changed.connect(_on_xp_changed)
			print("✅ Sistema de level conectado")
			
			# Atualiza UI inicial
			_update_level_ui(1)
			_update_xp_ui(0, player.player_level.xp_to_next_level)
	else:
		push_error("❌ Player não encontrado!")
	
	# Configura spawner
	if enemy_spawner:
		print("✅ Enemy Spawner encontrado")
		# Define cenas de inimigos se não estiverem configuradas
		if enemy_spawner.enemy_scenes.is_empty():
			var alien_scene = load("res://src/enemy/alien/alien.tscn")
			if alien_scene:
				enemy_spawner.enemy_scenes = [alien_scene]
				print("✅ Alien scene carregada")
		
		if enemy_spawner.boss_scenes.is_empty():
			var boss_scene = load("res://src/enemy/alien/boss_alien.tscn")
			if boss_scene:
				enemy_spawner.boss_scenes = [boss_scene]
				print("✅ Boss scene carregada")
				
		# Conecta sinais do spawner
		enemy_spawner.wave_started.connect(_on_wave_started_spawner)
		enemy_spawner.wave_completed.connect(_on_wave_completed_spawner)
	else:
		push_error("❌ Enemy Spawner não encontrado!")
	
	# Configura UI
	if upgrade_ui:
		print("✅ Upgrade UI encontrada")
		upgrade_ui.hide()
		if player and player.upgrade_manager:
			upgrade_ui.upgrade_selected.connect(_on_upgrade_selected)
	else:
		push_error("❌ Upgrade UI não encontrada!")
	
	# Registra pools
	_register_object_pools()
	
	# Conecta sinais do EventBus
	_connect_event_bus_signals()
	
	# Atualiza UI inicial
	_update_health_ui(player.health if player else 100, player.max_health if player else 100)
	
	print("\n=== JOGO INICIADO ===\n")

func _register_object_pools() -> void:
	print("\n📦 Registrando Object Pools...")
	
	# Pool de bullets
	var bullet_scene = load("res://src/weapons/projectiles/bullet/bullet.tscn")
	if bullet_scene:
		ObjectPool.register_pool("bullet", bullet_scene, 50)
		print("  ✅ Pool de bullets registrado")
	else:
		push_error("  ❌ Bullet scene não encontrada")

func _connect_event_bus_signals() -> void:
	print("\n🔌 Conectando sinais do EventBus...")
	
	if not EventBus:
		push_error("  ❌ EventBus não encontrado!")
		return
	
	# Conecta sinais de XP
	if not EventBus.enemy_died.is_connected(_on_enemy_died):
		EventBus.enemy_died.connect(_on_enemy_died)
		print("  ✅ Sinal enemy_died conectado")
	
	if not EventBus.boss_died.is_connected(_on_boss_died):
		EventBus.boss_died.connect(_on_boss_died)
		print("  ✅ Sinal boss_died conectado")
	
	# Conecta sinais de wave
	if not EventBus.wave_started.is_connected(_on_wave_started):
		EventBus.wave_started.connect(_on_wave_started)
		print("  ✅ Sinal wave_started conectado")
	
	if not EventBus.wave_completed.is_connected(_on_wave_completed):
		EventBus.wave_completed.connect(_on_wave_completed)
		print("  ✅ Sinal wave_completed conectado")
		
	# Conecta sinais de player
	if not EventBus.player_health_changed.is_connected(_on_player_health_changed):
		EventBus.player_health_changed.connect(_on_player_health_changed)
		print("  ✅ Sinal player_health_changed conectado")

func _process(_delta: float) -> void:
	# Atualiza contador de inimigos
	if enemies_label:
		var enemy_count = get_tree().get_nodes_in_group("enemies").size()
		enemies_label.text = "Enemies: %d" % enemy_count

func _on_enemy_died(enemy: Node, xp_amount: int) -> void:
	if player and player.player_level:
		player.player_level.add_xp(xp_amount)

func _on_boss_died(boss: Node, xp_amount: int) -> void:
	if player and player.player_level:
		player.player_level.add_xp(xp_amount)
		print("🎉 Boss derrotado! +%d XP" % xp_amount)

func _on_wave_started(wave_number: int) -> void:
	print("🌊 Wave %d iniciada!" % wave_number)

func _on_wave_completed(wave_number: int) -> void:
	print("✅ Wave %d completa!" % wave_number)

func _on_wave_started_spawner(wave_number: int, is_boss: bool) -> void:
	if wave_label:
		wave_label.text = "Wave %d%s" % [wave_number, " (BOSS)" if is_boss else ""]

func _on_wave_completed_spawner(wave_number: int) -> void:
	pass

func _on_player_level_up(new_level: int) -> void:
	print("🎉 Level Up! Nível %d" % new_level)
	_update_level_ui(new_level)
	if upgrade_ui:
		upgrade_ui.open()

func _on_upgrade_selected(upgrade_id: String) -> void:
	if player and player.upgrade_manager:
		player.upgrade_manager.apply_upgrade(upgrade_id)
		print("⬆️ Upgrade aplicado: %s" % upgrade_id)

func _on_xp_changed(current_xp: int, xp_to_next: int) -> void:
	_update_xp_ui(current_xp, xp_to_next)

func _on_player_health_changed(current_health: float, max_health: float) -> void:
	_update_health_ui(current_health, max_health)

func _update_health_ui(current: float, max_hp: float) -> void:
	if health_bar:
		health_bar.max_value = max_hp
		health_bar.value = current

func _update_xp_ui(current: int, needed: int) -> void:
	if xp_bar:
		xp_bar.max_value = needed
		xp_bar.value = current

func _update_level_ui(level: int) -> void:
	if level_label:
		level_label.text = "Level %d" % level