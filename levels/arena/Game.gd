extends Node2D

enum EnemyType { ALIEN }
enum Directions { UP, DOWN, LEFT, RIGHT }

@export var player: NodePath
@export var camera: NodePath

@export var enemy_scenes := {
	EnemyType.ALIEN: preload("res://src/enemy/alien/alien.tscn"),
}

@export var spawn_interval := 0.25
@export var base_enemies := 5
@export var growth_rate := 1.5
@export var boss_every_n_waves := 3

var enemy_weights: Dictionary[int, int] = { EnemyType.ALIEN: 60 }

var wave: int = 1
var is_boss_wave: bool = false
var enemies_to_spawn: int = 0
var enemies_spawned: int = 0
var alive_enemies: int = 0
var boss_alive: bool = false
var spawn_timer: float = 0.0

# Funções de spawn nas bordas da câmera
var spawn_functions := {
	Directions.UP: func(cam_pos: Vector2, viewport_size: Vector2, margin: float) -> Vector2:
		return Vector2(
			randf_range(cam_pos.x - viewport_size.x / 2.0, cam_pos.x + viewport_size.x / 2.0),
			cam_pos.y - viewport_size.y / 2.0 - margin
		),

	Directions.DOWN: func(cam_pos: Vector2, viewport_size: Vector2, margin: float) -> Vector2:
		return Vector2(
			randf_range(cam_pos.x - viewport_size.x / 2.0, cam_pos.x + viewport_size.x / 2.0),
			cam_pos.y + viewport_size.y / 2.0 + margin
		),

	Directions.LEFT: func(cam_pos: Vector2, viewport_size: Vector2, margin: float) -> Vector2:
		return Vector2(
			cam_pos.x - viewport_size.x / 2.0 - margin,
			randf_range(cam_pos.y - viewport_size.y / 2.0, cam_pos.y + viewport_size.y / 2.0)
		),

	Directions.RIGHT: func(cam_pos: Vector2, viewport_size: Vector2, margin: float) -> Vector2:
		return Vector2(
			cam_pos.x + viewport_size.x / 2.0 + margin,
			randf_range(cam_pos.y - viewport_size.y / 2.0, cam_pos.y + viewport_size.y / 2.0)
		),
}


func _ready():
	randomize()
	print("[Game] Inicializando...")

	# Registra pools de objetos
	_register_pools()

	# Configura player
	_setup_player()

	# Conecta eventos do EventBus
	_connect_events()

	# Conecta UI de upgrade
	_connect_upgrade_ui()

	# Inicia primeira wave
	_start_wave(wave)


func _register_pools():
	print("[Game] Registrando object pools...")
	ObjectPool.register_pool("enemy_alien", preload("res://src/enemy/alien/alien.tscn"), 50, 400, true, self)
	ObjectPool.register_pool("enemy_boss_alien", preload("res://src/enemy/alien/boss_alien.tscn"), 1, 4, true, self)
	ObjectPool.register_pool("bullet", preload("res://src/weapons/projectiles/bullet/bullet.tscn"), 60, 240, true, self)
	ObjectPool.register_pool("fx_fire_explosion", preload("res://src/vfx/fire_explosion.tscn"), 12, 48, true, self)
	ObjectPool.register_pool("fx_lightning_bolt", preload("res://src/vfx/lightning_bolt.tscn"), 8, 32, true, self)
	ObjectPool.register_pool("fx_lightning_strike", preload("res://src/vfx/lightning_strike.tscn"), 8, 32, true, self)


func _setup_player():
	var p = get_node_or_null(player)
	if p:
		if not p.is_in_group("player"):
			p.add_to_group("player")
		print("[Game] Player configurado: %s" % p.name)
	else:
		push_error("[Game] Player não encontrado no caminho: %s" % player)


func _connect_events():
	if not EventBus:
		push_error("[Game] EventBus não encontrado!")
		return
	
	print("[Game] Conectando eventos...")
	EventBus.enemy_spawned.connect(_on_enemy_spawned)
	EventBus.enemy_died.connect(_on_enemy_died)
	EventBus.boss_spawned.connect(_on_boss_spawned)
	EventBus.boss_died.connect(_on_boss_died)


func _connect_upgrade_ui():
	var ui := get_node_or_null("UI/UpgradeUI")
	var p := get_node_or_null(player)
	
	if not ui:
		push_warning("[Game] UpgradeUI não encontrada em UI/UpgradeUI")
		return
	
	if not p:
		push_warning("[Game] Player não encontrado")
		return
	
	var upgrade_mgr = p.get_node_or_null("UpgradeManager")
	if not upgrade_mgr:
		push_warning("[Game] UpgradeManager não encontrado no Player")
		return
	
	# Conecta level up para abrir UI
	if EventBus and not EventBus.player_leveled_up.is_connected(func(_level: int):
		print("[Game] Player subiu de nível! Abrindo UI de upgrade...")
		if ui:
			ui.open()
		):
		EventBus.player_leveled_up.connect(func(_level: int):
			print("[Game] Player subiu de nível! Abrindo UI de upgrade...")
			if ui:
				ui.open()
		)

	# Conecta seleção de upgrade
	if ui and ui.has_signal("upgrade_selected"):
		if not ui.upgrade_selected.is_connected(func(id: String):
			print("[Game] Upgrade selecionado: %s" % id)
			var player_node = get_node(player) if player else null
			if player_node:
				if upgrade_mgr and upgrade_mgr.has_method("apply_upgrade"):
					upgrade_mgr.apply_upgrade(id)
					print("[Game] Upgrade aplicado com sucesso!")
				else:
					push_error("[Game] UpgradeManager não encontrado ou método apply_upgrade não disponível!")
			else:
				push_error("[Game] Player não encontrado!")
		):
			ui.upgrade_selected.connect(func(id: String):
				print("[Game] Upgrade selecionado: %s" % id)
				var player_node = get_node(player) if player else null
				if player_node:
					if upgrade_mgr and upgrade_mgr.has_method("apply_upgrade"):
						upgrade_mgr.apply_upgrade(id)
						print("[Game] Upgrade aplicado com sucesso!")
					else:
						push_error("[Game] UpgradeManager não encontrado ou método apply_upgrade não disponível!")
				else:
					push_error("[Game] Player não encontrado!")
			)

	print("[Game] UI de upgrade conectada")


func _process(delta):
	if is_boss_wave:
		return
	
	if enemies_spawned < enemies_to_spawn:
		spawn_timer -= delta
		if spawn_timer <= 0.0:
			_spawn_enemy()
			spawn_timer = spawn_interval


# ===================== Waves =====================
func _start_wave(w: int) -> void:
	is_boss_wave = (boss_every_n_waves > 0 and w % boss_every_n_waves == 0)

	if is_boss_wave:
		enemies_to_spawn = 0
		enemies_spawned = 0
		alive_enemies = 0
		boss_alive = false

		if EventBus:
			EventBus.wave_started.emit(w, true, 0)

		_spawn_boss()
		print("[Game] === BOSS WAVE %d ===" % w)
	else:
		enemies_to_spawn = int(base_enemies * pow(growth_rate, max(0, w - 1)))
		enemies_spawned = 0
		alive_enemies = 0
		boss_alive = false
		spawn_timer = 0.05
		
		if EventBus:
			EventBus.wave_started.emit(w, false, enemies_to_spawn)

		print("[Game] Wave %d: vai spawnar %d inimigos." % [w, enemies_to_spawn])


# ===================== Eventos =====================
func _on_enemy_spawned(node: Node) -> void:
	alive_enemies += 1


func _on_enemy_died(node: Node, xp_amount: int) -> void:
	alive_enemies = max(0, alive_enemies - 1)
	
	# Verifica se a wave foi limpa
	if not is_boss_wave and enemies_spawned >= enemies_to_spawn and alive_enemies == 0:
		print("[Game] Wave %d limpa! Próxima wave..." % wave)
		if EventBus:
			EventBus.wave_cleared.emit(wave)
		wave += 1
		_start_wave(wave)


func _on_boss_spawned(node: Node) -> void:
	boss_alive = true
	print("[Game] Boss spawned!")


func _on_boss_died(node: Node, xp_amount: int) -> void:
	boss_alive = false
	print("[Game] Boss derrotado!")
	
	if is_boss_wave:
		wave += 1
		_start_wave(wave)


# ===================== Spawns =====================
func _spawn_enemy():
	var p: Node2D = get_node_or_null(player)
	if p == null:
		push_warning("[Game] Player não encontrado para spawn.")
		return

	var etype: int = _choose_enemy(_get_possible_enemies_for_wave(wave))
	
	if etype == EnemyType.ALIEN:
		var e = ObjectPool.acquire(
			"enemy_alien",
			self,
			_get_spawn_area_position(),
			0.0,
			{ "wave": wave, "target": p }
		)
		if e:
			enemies_spawned += 1
			if EventBus:
				EventBus.enemy_spawned.emit(e)
	else:
		# Fallback para tipos não poolados
		var ps: PackedScene = enemy_scenes.get(etype)
		if not ps:
			push_error("[Game] Cena não encontrada para EnemyType: %s" % [str(etype)])
			return
		
		var e2: Node2D = ps.instantiate()
		e2.global_position = _get_spawn_area_position()
		
		if e2.has_method("scale_with_wave"):
			e2.scale_with_wave(wave)
		
		if e2.has_variable("target"):
			e2.set("target", p)
		
		add_child(e2)
		enemies_spawned += 1
		
		if EventBus:
			EventBus.enemy_spawned.emit(e2)


func _spawn_boss():
	var p: Node2D = get_node_or_null(player)
	var pos: Vector2 = _get_spawn_area_position()

	var boss = ObjectPool.acquire(
		"enemy_boss_alien",
		self,
		pos,
		0.0,
		{ "wave": wave, "target": p }
	)
	
	if boss:
		if not boss.is_in_group("boss"):
			boss.add_to_group("boss")
		
		if EventBus:
			EventBus.boss_spawned.emit(boss)
		
		print("[Game] Boss spawned (pool) na wave %d" % wave)
	else:
		push_error("[Game] Falha ao adquirir boss do pool 'enemy_boss_alien'")


# ===================== Helpers =====================
func _get_possible_enemies_for_wave(w: int) -> Array[int]:
	return [EnemyType.ALIEN]


func _choose_enemy(possible_enemies: Array[int]) -> int:
	var total: int = 0
	for e: int in possible_enemies:
		total += int(enemy_weights.get(e, 1))

	var r: int = randi_range(0, max(1, total) - 1)

	for e: int in possible_enemies:
		r -= int(enemy_weights.get(e, 1))
		if r < 0:
			return e
	
	return possible_enemies[0]


func _get_spawn_area_position() -> Vector2:
	var cam: Node2D = get_node_or_null(camera)
	if cam == null:
		return Vector2.ZERO
	
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var cam_pos: Vector2 = cam.global_position
	var margin := 120.0
	var side: int = Directions.values()[randi() % Directions.size()]
	
	return spawn_functions[side].call(cam_pos, viewport_size, margin)
