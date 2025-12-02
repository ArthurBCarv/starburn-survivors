extends Node
class_name EnemySpawner

## Sistema de spawn de inimigos com waves infinitas e dificuldade crescente

signal wave_started(wave_number: int, is_boss_wave: bool)
signal wave_completed(wave_number: int)
signal all_enemies_cleared()

# Configurações básicas
@export_group("Spawn Settings")
@export var enabled := true
@export var spawn_margin := 100.0  # Distância fora da câmera para spawnar
@export var min_spawn_distance := 150.0  # Distância mínima do player

# Configurações de waves
@export_group("Wave Settings")
@export var wave_interval := 5.0  # Tempo entre waves (diminui com o tempo)
@export var min_wave_interval := 5.0  # Intervalo mínimo entre waves
@export var wave_interval_decrease := 0.5  # Quanto diminui por wave

# Configurações de dificuldade
@export_group("Difficulty Scaling")
@export var enemies_per_wave_base := 5  # Inimigos iniciais
@export var enemies_per_wave_growth := 1.2  # Multiplicador de crescimento
@export var max_enemies_per_wave := 100  # Limite máximo de inimigos por wave
@export var boss_wave_interval := 5  # Boss a cada X waves
@export var elite_spawn_chance := 0.1  # Chance de spawnar elite (aumenta com waves)
@export var elite_chance_growth := 0.02  # Quanto aumenta por wave

# Configurações de boss waves
@export_group("Boss Wave Settings")
@export var boss_minions_base := 3  # Inimigos que spawnam com o boss
@export var boss_minions_growth := 1.5  # Crescimento de minions por boss wave

# Cenas de inimigos
@export_group("Enemy Scenes")
@export var enemy_scenes: Array[PackedScene] = []
@export var elite_enemy_scenes: Array[PackedScene] = []  # Inimigos mais fortes
@export var boss_scenes: Array[PackedScene] = []

# Estado atual
var current_wave := 0
var enemies_spawned := 0
var enemies_alive := 0
var is_boss_wave := false
var wave_active := false
var total_enemies_killed := 0
var current_wave_interval := 0.0

# Referências
var _wave_timer: Timer
var _player: Node2D
var _camera: Camera2D

func _ready() -> void:
	current_wave_interval = wave_interval

	# Conecta aos eventos de morte
	if EventBus:
		EventBus.enemy_died.connect(_on_enemy_died)
		EventBus.boss_died.connect(_on_boss_died)

	# Cria timer de wave
	_wave_timer = Timer.new()
	_wave_timer.one_shot = true
	_wave_timer.timeout.connect(_start_next_wave)
	add_child(_wave_timer)

	# Busca player e câmera
	call_deferred("_find_player_and_camera")

	# Inicia primeira wave
	if enabled:
		call_deferred("_start_next_wave")

	print("[EnemySpawner] Sistema de waves infinitas iniciado!")
	print("[EnemySpawner] Configuração: %d inimigos base, crescimento %.1fx" % [enemies_per_wave_base, enemies_per_wave_growth])

func _find_player_and_camera() -> void:
	_player = get_tree().get_first_node_in_group("player")
	if _player:
		_camera = _player.get_viewport().get_camera_2d()

func _start_next_wave() -> void:
	if not enabled:
		return

	current_wave += 1
	is_boss_wave = (current_wave % boss_wave_interval == 0)

	var enemy_count = _calculate_enemy_count()
	enemies_spawned = 0
	enemies_alive = 0
	wave_active = true

	# Diminui intervalo entre waves progressivamente
	current_wave_interval = max(min_wave_interval, wave_interval - (current_wave * wave_interval_decrease))

	var wave_type = "BOSS WAVE" if is_boss_wave else "Wave Normal"
	print("[EnemySpawner] ═══════════════════════════════════════")
	print("[EnemySpawner] 🌊 WAVE %d - %s" % [current_wave, wave_type])
	print("[EnemySpawner] 👾 Inimigos: %d" % enemy_count)
	print("[EnemySpawner] ⏱️  Próxima wave em: %.1fs" % current_wave_interval)
	print("[EnemySpawner] 💀 Total mortos: %d" % total_enemies_killed)
	print("[EnemySpawner] ═══════════════════════════════════════")

	wave_started.emit(current_wave, is_boss_wave)
	if EventBus:
		EventBus.wave_started.emit(current_wave, is_boss_wave, enemy_count)

	# Spawna inimigos
	_spawn_wave(enemy_count)

func _calculate_enemy_count() -> int:
	if is_boss_wave:
		# Boss + minions crescentes
		var minions = int(boss_minions_base * pow(boss_minions_growth, (current_wave / boss_wave_interval) - 1))
		return 1 + minions  # Boss + minions

	# Fórmula de crescimento exponencial com limite
	var count = int(enemies_per_wave_base * pow(enemies_per_wave_growth, current_wave - 1))
	return min(count, max_enemies_per_wave)

func _spawn_wave(count: int) -> void:
	for i in range(count):
		# Delay entre spawns (diminui com waves)
		var spawn_delay = randf_range(0.1, 0.5) / (1.0 + current_wave * 0.05)
		await get_tree().create_timer(spawn_delay).timeout
		_spawn_enemy(i == 0 and is_boss_wave)  # Primeiro inimigo é o boss se for boss wave

func _spawn_enemy(force_boss: bool = false) -> void:
	if not _player:
		_find_player_and_camera()
		if not _player:
			return

	var enemy_scene: PackedScene
	var enemy: Node

	if force_boss:
		if enemy_scenes.size() > 0:
			enemy_scene = enemy_scenes.pick_random()
			enemy = BossFactory.create_boss_from_alien(enemy_scene, current_wave)
			get_tree().current_scene.add_child(enemy)
			enemy.global_position = _get_spawn_position_outside_camera()

			if enemy.has_method("set") and _player:
				enemy.set("target", _player)

			enemy.add_to_group("boss")
			print("[EnemySpawner] 👑 BOSS SPAWNOU! Wave %d - Scale: %.1fx" % [current_wave, 1.0 + (current_wave * 0.3)])

			enemies_spawned += 1
			enemies_alive += 1

			if EventBus:
				EventBus.boss_spawned.emit(enemy)
		else:
			push_warning("[EnemySpawner] Nenhuma cena de inimigo para criar boss!")
		return

	if _should_spawn_elite() and elite_enemy_scenes.size() > 0:
		enemy_scene = elite_enemy_scenes.pick_random()
		print("[EnemySpawner] ⭐ Elite spawnou!")
	elif enemy_scenes.size() > 0:
		enemy_scene = enemy_scenes.pick_random()
	else:
		push_warning("[EnemySpawner] Nenhuma cena de inimigo configurada!")
		return

	var spawn_pos = _get_spawn_position_outside_camera()

	enemy = enemy_scene.instantiate()
	get_tree().current_scene.add_child(enemy)
	enemy.global_position = spawn_pos

	if enemy.has_method("scale_with_wave"):
		enemy.scale_with_wave(current_wave)

	if enemy.has_method("set") and _player:
		enemy.set("target", _player)

	enemies_spawned += 1
	enemies_alive += 1

	if EventBus:
		EventBus.enemy_spawned.emit(enemy)

func _should_spawn_elite() -> bool:
	# Chance de spawnar elite aumenta com as waves
	var current_elite_chance = elite_spawn_chance + (current_wave * elite_chance_growth)
	current_elite_chance = min(current_elite_chance, 0.5)  # Máximo 50% de chance
	return randf() < current_elite_chance

func _get_spawn_position_outside_camera() -> Vector2:
	if not _camera or not _player:
		# Fallback: spawna em círculo ao redor do player
		var angle = randf() * TAU
		var distance = min_spawn_distance + randf_range(0, 100)
		return _player.global_position + Vector2(cos(angle), sin(angle)) * distance

	# Pega viewport da câmera
	var viewport_size = get_viewport().get_visible_rect().size
	var camera_pos = _camera.global_position
	var zoom = _camera.zoom

	# Calcula limites visíveis da câmera
	var half_size = (viewport_size / zoom) * 0.5
	var camera_rect = Rect2(camera_pos - half_size, half_size * 2)

	# Expande o retângulo com margem
	camera_rect = camera_rect.grow(spawn_margin)

	# Escolhe um lado aleatório (0=cima, 1=direita, 2=baixo, 3=esquerda)
	var side = randi() % 4
	var spawn_pos: Vector2

	match side:
		0:  # Cima
			spawn_pos = Vector2(
				randf_range(camera_rect.position.x, camera_rect.end.x),
				camera_rect.position.y
			)
		1:  # Direita
			spawn_pos = Vector2(
				camera_rect.end.x,
				randf_range(camera_rect.position.y, camera_rect.end.y)
			)
		2:  # Baixo
			spawn_pos = Vector2(
				randf_range(camera_rect.position.x, camera_rect.end.x),
				camera_rect.end.y
			)
		3:  # Esquerda
			spawn_pos = Vector2(
				camera_rect.position.x,
				randf_range(camera_rect.position.y, camera_rect.end.y)
			)

	# Garante distância mínima do player
	if _player and spawn_pos.distance_to(_player.global_position) < min_spawn_distance:
		var dir = (spawn_pos - _player.global_position).normalized()
		spawn_pos = _player.global_position + dir * min_spawn_distance

	return spawn_pos

func _on_enemy_died(enemy: Node, xp: int) -> void:
	enemies_alive -= 1
	total_enemies_killed += 1
	_check_wave_completion()

func _on_boss_died(boss: Node, xp: int) -> void:
	enemies_alive -= 1
	total_enemies_killed += 1
	print("[EnemySpawner] 💀 BOSS DERROTADO!")
	_check_wave_completion()

func _check_wave_completion() -> void:
	if not wave_active:
		return

	if enemies_alive <= 0 and enemies_spawned > 0:
		wave_active = false
		print("[EnemySpawner] ✅ Wave %d completada! (%d/%d inimigos mortos)" % [current_wave, enemies_spawned, enemies_spawned])

		wave_completed.emit(current_wave)
		all_enemies_cleared.emit()

		if EventBus:
			EventBus.wave_cleared.emit(current_wave)

		# Inicia timer para próxima wave (INFINITA!)
		if enabled:
			print("[EnemySpawner] ⏳ Próxima wave em %.1f segundos..." % current_wave_interval)
			_wave_timer.start(current_wave_interval)

func stop_spawning() -> void:
	enabled = false
	_wave_timer.stop()
	print("[EnemySpawner] ⏸️  Spawn pausado")

func resume_spawning() -> void:
	enabled = true
	if not wave_active:
		_start_next_wave()
	print("[EnemySpawner] ▶️  Spawn retomado")

# Funções de debug/utilidade
func get_current_wave() -> int:
	return current_wave

func get_enemies_alive() -> int:
	return enemies_alive

func get_total_killed() -> int:
	return total_enemies_killed

func get_difficulty_multiplier() -> float:
	# Retorna um multiplicador de dificuldade baseado na wave atual
	return pow(enemies_per_wave_growth, current_wave - 1)
