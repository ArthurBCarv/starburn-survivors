extends CharacterBody2D

@export var speed := 600.0
@export var bullet_scene: PackedScene
@export var fire_rate := 0.05
@export var max_health := 100
@export var detection_radius := 250.0
@export var arena_rect := Rect2(Vector2.ZERO, Vector2(2000, 2000))
@export var bullet_damage := 10.0

var closest_enemy: Node2D = null
var health := 0.0
var last_shot_time := 0.0
var move_dir := Vector2.RIGHT
# Variável para chance de crítico
var crit_chance := 0.0

@onready var upgrade_manager: UpgradeManager = $UpgradeManager
@onready var player_level: PlayerLevel = $PlayerLevel
@onready var animation: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	health = float(max_health)
	add_to_group("player")

	# Emite HP inicial para o HUD
	if EventBus:
		EventBus.player_health_changed.emit(health, max_health)

	# Conecta level up ao upgrade manager
	if player_level:
		player_level.level_up.connect(_on_level_up)

	# Conecta morte de inimigos para ganhar XP
	if EventBus:
		EventBus.enemy_died.connect(_on_enemy_died)
		EventBus.boss_died.connect(_on_boss_died)

func _on_enemy_died(enemy: Node, xp_amount: int):
	if player_level:
		player_level.add_xp(xp_amount)
		print("[Player] Ganhou %d XP de inimigo" % xp_amount)

func _on_boss_died(boss: Node, xp_amount: int):
	if player_level:
		player_level.add_xp(xp_amount)
		print("[Player] Ganhou %d XP de boss" % xp_amount)

func _process(delta):

	
	_move(delta)
	_flip()
	_auto_shoot(delta)
	_animation(delta)
	if closest_enemy != null:
		var dir = (closest_enemy.global_position - $Gun.global_position)
		var angle = dir.angle()
		if dir.x < 0:
			$Gun.scale.y = -1
		else:
			$Gun.scale.y = 1
		$Gun.rotation  =  lerp_angle($Gun.rotation, angle, fire_rate)

	# DEBUG: Pressione T para ganhar XP rapidamente
	if Input.is_action_just_pressed("ui_text_completion_accept") or Input.is_key_pressed(KEY_T):
		if player_level:
			player_level.add_xp(10)
			print("[Player DEBUG] +10 XP (Total: %d/%d)" % [player_level.xp, player_level.xp_to_next_level])

func _move(delta):
	var input_vector = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if input_vector != Vector2.ZERO:
		move_dir = input_vector.normalized()
	velocity = input_vector * speed
	move_and_slide()

func _animation(delta):
	if velocity.is_zero_approx():
		animation.play("Idle")
		animation.speed_scale = 4
	else:
		animation.play("Run")
		var vel: float = float(velocity.x)*velocity.x +float(velocity.y)*velocity.y
		animation.speed_scale = sqrt(vel) / 100

func _flip():
	if velocity.x < 0:
		animation.flip_h = true
	elif velocity.x > 0:
		animation.flip_h = false
func _auto_shoot(delta):
	# Ajusta arena_rect para corresponder aos limites da câmera ativa (Camera2D), se houver
	var enemies = get_tree().get_nodes_in_group("enemies")
	var closest_dist := INF
	
	for e in enemies:
		if e and e.is_inside_tree():
			var dist = global_position.distance_to(e.global_position)
			if dist < closest_dist and dist <= detection_radius:
				closest_dist = dist
				closest_enemy = e
	var now_sec := Time.get_ticks_msec() / 1000.0
	if closest_enemy and (now_sec - last_shot_time) > fire_rate:
		var dir = (closest_enemy.global_position - global_position).normalized()
		# Efeito visual de disparo
		VFXManager.spawn_muzzle_flash(global_position + dir * 20)
		
		var bullet = ObjectPool.acquire("bullet", get_parent(), global_position)
		if bullet:
			if bullet.has_method("on_spawn_from"): 
				bullet.on_spawn_from(self)
			bullet.direction = dir
			bullet.damage = bullet_damage
		last_shot_time = now_sec

func take_damage(amount):
	health -= amount

	# Emite mudança de HP
	if EventBus:
		EventBus.player_health_changed.emit(health, max_health)

	if health <= 0:
		_on_death()

func _on_death():
	print("[Player] Morreu!")
	if EventBus:
		EventBus.player_died.emit()
	queue_free()

func _on_level_up(new_level: int):
	print("[Player] Level UP! Novo nível: %d" % new_level)

	# Abre a UI de upgrade
	var upgrade_ui = get_tree().get_first_node_in_group("upgrade_ui")
	if upgrade_ui and upgrade_ui.has_method("open"):
		print("[Player] Abrindo UI de upgrade...")
		upgrade_ui.open()
	else:
		push_error("[Player] UpgradeUI não encontrada no grupo 'upgrade_ui'!")

# Métodos para upgrades
func increase_damage(amount: float) -> void:
	bullet_damage += amount
	print("[Player] Dano aumentado para %.1f" % bullet_damage)

func increase_fire_rate(amount: float) -> void:
	# fire_rate representa o tempo entre tiros; diminuir o valor aumenta a cadência
	fire_rate = max(0.05, fire_rate - amount)
	print("[Player] Velocidade de tiro aumentada para %.2f" % fire_rate)

func increase_crit_chance(amount: float) -> void:
	# Placeholder para críticos futuros; implementar crit_chance quando necessário
	crit_chance = clamp(crit_chance + amount, 0.0, 100.0)
	print("[Player] Chance de crítico ajustada para %.2f%%" % crit_chance)

func increase_speed(amount: float) -> void:
	speed += amount
	print("[Player] Velocidade aumentada para %.1f" % speed)

func activate_super_attack() -> void:
	# Placeholder para super ataque (implementar lógica real conforme o design)
	print("[Player] Super ataque ativado!")

func get_aim_direction() -> Vector2:
	return move_dir

func apply_upgrade(upgrade) -> void:
	if upgrade == null: 
		return
	
	speed += upgrade.speed_bonus
	bullet_damage += upgrade.damage_bonus
	fire_rate = max(0.01, fire_rate - upgrade.fire_rate_bonus)
	detection_radius = max(0.0, detection_radius + upgrade.detection_radius_bonus)
	
	print("[Player] Upgrade aplicado - Speed: %.1f, Damage: %.1f, FireRate: %.3f, Range: %.1f" % [speed, bullet_damage, fire_rate, detection_radius])

func get_level() -> int:
	return player_level.level if player_level else 1

func get_xp() -> int:
	return player_level.xp if player_level else 0
