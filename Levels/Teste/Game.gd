extends Node2D

enum EnemyType { ALIEN }



@export var player: NodePath
@export var camera: NodePath

@export var enemy_scenes := {
	EnemyType.ALIEN: preload("res://src/enemy/alien/alien.tscn"),
}

var enemy_weights := {
	EnemyType.ALIEN: 60,
}

var wave := 1
var enemies_to_spawn := 0
var enemies_spawned := 0
var spawn_timer := 0.0
@export var spawn_interval := 0.25  # segundos entre spawns

var last_enemy_instance: Node = null

enum Directions {UP,DOWN,LEFT,RIGHT}

var spawn_functions := {
	Directions.UP: func(cam_pos, viewport_size, margin):
		return Vector2(randf_range(cam_pos.x - viewport_size.x/2, cam_pos.x + viewport_size.x/2), cam_pos.y - viewport_size.y/2 - margin),

	Directions.DOWN: func(cam_pos, viewport_size, margin):
		return Vector2(randf_range(cam_pos.x - viewport_size.x/2, cam_pos.x + viewport_size.x/2), cam_pos.y + viewport_size.y/2 + margin),

	Directions.LEFT: func(cam_pos, viewport_size, margin):
		return Vector2(cam_pos.x - viewport_size.x/2 - margin, randf_range(cam_pos.y - viewport_size.y/2, cam_pos.y + viewport_size.y/2)),

	Directions.RIGHT: func(cam_pos, viewport_size, margin):
		return Vector2(cam_pos.x + viewport_size.x/2 + margin, randf_range(cam_pos.y - viewport_size.y/2, cam_pos.y + viewport_size.y/2)),}

func _ready():
	randomize()
	start_wave()

func _process(delta):
	# controlar spawn incremental
	if enemies_spawned < enemies_to_spawn:
		spawn_timer -= delta
		if spawn_timer <= 0:
			spawn_enemy()
			spawn_timer = spawn_interval

	# checar se acabou a wave
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.size() == 0 and enemies_spawned >= enemies_to_spawn:
		wave += 1
		print("Starting wave ", wave)
		start_wave()

func get_possible_enemies_for_wave(wave: int) -> Array:
	var enemys_possibles = [EnemyType.ALIEN]
	
	# Se quiser implementar novos inimigos faça assim:
	# if wave > X:
	#    enemys_possibles.append(novo_inimigo)
	
	return enemys_possibles
	

func choose_enemy(possible_enemies: Array) -> int:
	var total = 0
	for e in possible_enemies:
		total += enemy_weights.get(e, 1)
	var r = randi() % total
	for e in possible_enemies:
		r -= enemy_weights.get(e, 1)
		if r < 0:
			return e
	return possible_enemies[0]

func start_wave():
	var base_enemies := 5
	var growth_rate := 1.5
	enemies_to_spawn = int(base_enemies * pow(growth_rate, wave - 1))
	enemies_spawned = 0
	spawn_timer = 0.1 # start rápido
	print("Wave ", wave, " vai spawnar ", enemies_to_spawn, " inimigos.")

	# Boss check
	if wave % 3 == 0:
		call_deferred("spawn_boss")

func spawn_enemy():
	var player_node = get_node(player)
	if not player_node:
		return

	var possible_enemies = get_possible_enemies_for_wave(wave)
	var etype = choose_enemy(possible_enemies)
	var ps: PackedScene = enemy_scenes.get(etype)
	if not ps:
		push_error("Cena não encontrada para EnemyType: " + str(etype))
		return

	var enemy = ps.instantiate()
	enemy.global_position = get_spawn_area_position()
	enemy.target = player_node
	add_child(enemy)
	last_enemy_instance = enemy
	enemies_spawned += 1
	print("Spawned enemy ", etype)

func spawn_boss():
	if last_enemy_instance and player:
		var boss_node = BossFactory.make_boss(last_enemy_instance)
		if boss_node:
			boss_node.global_position = get_spawn_area_position()
			boss_node.target = get_node(player)
			add_child(boss_node)
			print("Boss spawned!")

# -----------------------
# Spawn Area (mais natural)
# -----------------------
func get_spawn_area_position() -> Vector2:
	var cam = get_node(camera)
	if not cam:
		return Vector2.ZERO
	var viewport_size = get_viewport().get_visible_rect().size
	var cam_pos = cam.global_position
	var margin := 120.0

	var side = Directions.values()[randi() % Directions.size()]
	return spawn_functions[side].call(cam_pos, viewport_size, margin)
