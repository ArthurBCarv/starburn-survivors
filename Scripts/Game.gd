extends Node2D

# =========================
# Configuração dos tipos de inimigos
# =========================
enum EnemyType { GOBLIN, SKELETON, ORC, BOSS }

# Mapear EnemyType para suas cenas
var enemy_scenes = {
	EnemyType.GOBLIN: preload("res://seenemies/Goblin.tscn"),
}

# Optional: peso de spawn (quanto maior, mais comum)
var enemy_weights = {
	EnemyType.GOBLIN: 60,
	EnemyType.SKELETON: 30,
	EnemyType.ORC: 10,
	EnemyType.BOSS: 0  # bosses spawnam separados
}

# =========================
# Export para player e câmera
# =========================
@export var player: NodePath
@export var camera: NodePath

# Wave atual
var wave := 1

func _ready():
	randomize()
	start_wave()

func _process(delta):
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.size() == 0:
		wave += 1
		print("Starting wave ", wave)
		start_wave()

# =========================
# Determina quais inimigos podem spawnar na wave
# =========================
func get_possible_enemies_for_wave(wave: int) -> Array:
	var enemies = [EnemyType.GOBLIN]

	if wave >= 2:
		enemies.append(EnemyType.SKELETON)
	if wave >= 4:
		enemies.append(EnemyType.ORC)

	# bosses spawnam a cada 3 waves
	if wave % 3 == 0:
		enemies.append(EnemyType.BOSS)

	return enemies

# =========================
# Escolhe um inimigo aleatório considerando peso
# =========================
func choose_enemy(possible_enemies: Array) -> EnemyType:
	var total_weight = 0
	for e in possible_enemies:
		total_weight += enemy_weights.get(e, 1)
	var r = randi() % total_weight
	for e in possible_enemies:
		r -= enemy_weights.get(e, 1)
		if r < 0:
			return e
	return possible_enemies[0]  # fallback

# =========================
# Spawna a wave de inimigos
# =========================
func start_wave():
	var player_node = get_node(player)
	if not player_node:
		push_error("Player não encontrado! Verifique o NodePath.")
		return

	var base_enemies := 5
	var growth_rate := 1.5
	var enemy_count = int(base_enemies * pow(growth_rate, wave - 1))
	print("Spawning ", enemy_count, " enemies")

	var possible_enemies = get_possible_enemies_for_wave(wave)

	for i in range(enemy_count):
		var spawn_pos = get_spawn_position()
		var enemy_type = choose_enemy(possible_enemies)

		# para boss, spawn separado
		if enemy_type == EnemyType.BOSS:
			if wave % 3 == 0:
				var boss_scene = enemy_scenes[EnemyType.BOSS]
				var boss = boss_scene.instantiate()
				boss.global_position = spawn_pos
				boss.target = player_node
				add_child(boss)
				print("Boss spawned at ", spawn_pos)
			continue

		var enemy_scene = enemy_scenes[enemy_type]
		var enemy = enemy_scene.instantiate()
		enemy.global_position = spawn_pos
		enemy.target = player_node
		add_child(enemy)
		print("Spawned ", enemy_type, " at ", spawn_pos)

# =========================
# Determina posição aleatória ao redor da câmera
# =========================
func get_spawn_position() -> Vector2:
	var cam = get_node(camera)
	var viewport_size = get_viewport().get_visible_rect().size
	var cam_pos = cam.global_position
	var margin := 90.0

	var side = randi() % 4
	var spawn_x: float
	var spawn_y: float

	match side:
		0:
			spawn_x = randf_range(cam_pos.x - viewport_size.x/2, cam_pos.x + viewport_size.x/2)
			spawn_y = cam_pos.y - viewport_size.y/2 - margin
		1:
			spawn_x = randf_range(cam_pos.x - viewport_size.x/2, cam_pos.x + viewport_size.x/2)
			spawn_y = cam_pos.y + viewport_size.y/2 + margin
		2:
			spawn_x = cam_pos.x - viewport_size.x/2 - margin
			spawn_y = randf_range(cam_pos.y - viewport_size.y/2, cam_pos.y + viewport_size.y/2)
		3:
			spawn_x = cam_pos.x + viewport_size.x/2 + margin
			spawn_y = randf_range(cam_pos.y - viewport_size.y/2, cam_pos.y + viewport_size.y/2)

	return Vector2(spawn_x, spawn_y)
