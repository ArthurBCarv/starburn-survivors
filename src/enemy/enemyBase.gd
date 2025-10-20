extends CharacterBody2D
class_name EnemyBase

@export var speed: float = 150.0
@export var base_health: float = 30.0
@export var base_damage: float = 10.0
@export var attack_cooldown: float = 0.5
@export var attack_range: float = 20.0
@export var xp_reward: int = 5
@export var death_particle_color: Color = Color.RED

var health: float
var damage: float
var target: Node2D
var can_attack := true
var stunned := false

var _is_pooled := false
var _dead_emitted := false
var _current_wave := 1

@onready var damage_component: DamageComponent = $DamageComponent

func _ready():
	health = base_health
	damage = base_damage
	add_to_group("enemies")

	# Adiciona componente de status effects se não existir
	if not has_node("StatusEffectComponent"):
		var sec = StatusEffectComponent.new()
		sec.name = "StatusEffectComponent"
		add_child(sec)
	
	# Adiciona componente de dano se não existir
	if not has_node("DamageComponent"):
		var dc = DamageComponent.new()
		dc.name = "DamageComponent"
		dc.max_health = base_health
		dc.show_damage_numbers = true
		dc.flash_on_damage = true
		add_child(dc)
		damage_component = dc
	
	# Conecta sinal de morte
	if damage_component:
		damage_component.died.connect(_on_damage_component_died)

	# Busca o player como alvo
	if target == null:
		var p = get_tree().get_first_node_in_group("player")
		if p and p is Node2D:
			target = p

func _physics_process(delta):
	if stunned:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	if target and target.is_inside_tree():
		var dir = (target.global_position - global_position).normalized()
		velocity = dir * speed
		move_and_slide()

		if can_attack and global_position.distance_to(target.global_position) < get_attack_range():
			_attack(target)

func scale_with_wave(wave: int) -> void:
	_current_wave = wave
	var health_multiplier := 1.2
	var damage_multiplier := 1.1
	health = base_health * pow(health_multiplier, max(0, wave - 1))
	damage = base_damage * pow(damage_multiplier, max(0, wave - 1))

	if damage_component:
		damage_component.max_health = health
		damage_component.current_health = health
		damage_component.reset_state()
func _on_damage_component_died() -> void:
	on_death()

func take_damage(amount: float, source: Node = null) -> void:
	print("[EnemyBase] %s recebendo dano: %.1f (tem DamageComponent: %s)" % [name, amount, damage_component != null])

	if damage_component:
		damage_component.take_damage(amount, source)
	else:
		# Fallback se não tiver DamageComponent
		print("[EnemyBase] AVISO: %s não tem DamageComponent, usando fallback" % name)
		health -= amount
		if health <= 0:
			on_death()

func set_stunned(s: bool) -> void:
	stunned = s

func _timer_attack_reset():
	var t = get_tree().create_timer(attack_cooldown)
	t.timeout.connect(func(): can_attack = true)

func _attack(player_node: Node) -> void:
	push_error("_attack não implementado em %s" % [name])

func get_attack_range() -> float:
	return attack_range

func on_death():
	if _dead_emitted: 
		return
	_dead_emitted = true
	
	# Efeito visual de morte
	VFXManager.spawn_enemy_death(global_position, death_particle_color)

	# Calcula XP baseado na wave
	var xp_amount := int(round(xp_reward * pow(1.1, max(0, _current_wave - 1))))
	
	# Boss dá 3x mais XP
	if is_in_group("boss"):
		xp_amount *= 3
		print("[Enemy] Boss morreu! XP: %d (Wave %d)" % [xp_amount, _current_wave])
		if EventBus:
			EventBus.boss_died.emit(self, xp_amount)
	else:
		print("[Enemy] Inimigo morreu! XP: %d (Wave %d)" % [xp_amount, _current_wave])
		if EventBus:
			EventBus.enemy_died.emit(self, xp_amount)

	# Retorna ao pool ou destroi
	if _is_pooled:
		ObjectPool.release(self)
	else:
		queue_free()

# ==================== Pool Hooks ====================
func pool_on_spawn(payload: Dictionary) -> void:
	_is_pooled = true
	_dead_emitted = false
	can_attack = true
	stunned = false
	velocity = Vector2.ZERO
	visible = true

	# Garante que o DamageComponent existe
	if not damage_component:
		damage_component = get_node_or_null("DamageComponent")

	# Limpa status effects
	var sec: StatusEffectComponent = get_node_or_null("StatusEffectComponent")
	if sec:
		sec.clear_all()

	# Define alvo
	if payload.has("target") and payload["target"] is Node2D:
		target = payload["target"]

	# Escala com a wave
	var wave := int(payload.get("wave", _current_wave))
	scale_with_wave(max(1, wave))

func pool_on_despawn() -> void:
	velocity = Vector2.ZERO
	visible = false
