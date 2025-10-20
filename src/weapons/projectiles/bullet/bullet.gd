extends Area2D
class_name Bullet

@export var speed := 400.0
@export var damage := 10.0
@export var lifetime := 2.0
@export var perfuration := 0
var direction := Vector2.ZERO

var _base_lifetime := 2.0
var abilities: Array = []
var _trail: Node = null

func _ready():
	_base_lifetime = lifetime
	if not is_connected("body_entered", Callable(self, "_on_body_entered")):
		connect("body_entered", Callable(self, "_on_body_entered"))
	
	# Spawna rastro de plasma
	_spawn_trail()

func _process(delta):
	position += direction * speed * delta
	lifetime -= delta
	if lifetime <= 0.0:
		_cleanup()
		ObjectPool.release(self)

func _on_body_entered(body):
	print("[Bullet] Colidiu com: %s (é inimigo: %s)" % [body.name, body.is_in_group("enemies")])

	if body.is_in_group("enemies"):
		# Efeito de impacto
		VFXManager.spawn_hit_impact(global_position)

		# Aplica dano
		if body.has_method("take_damage"):
			print("[Bullet] Aplicando dano de %.1f em %s" % [damage, body.name])
			body.take_damage(damage)
		else:
			print("[Bullet] ERRO: %s não tem método take_damage!" % body.name)

		# Chama habilidades
		for a in abilities:
			if a and a.has_method("on_projectile_hit"):
				a.on_projectile_hit(self, body)

		# Verifica perfuração
		if perfuration > 0:
			perfuration -= 1
		else:
			_cleanup()
			ObjectPool.release(self)

func _spawn_trail() -> void:
	if _trail:
		return
	_trail = VFXManager.spawn_plasma_trail(global_position, self)

func _cleanup() -> void:
	if _trail and is_instance_valid(_trail):
		_trail.reparent(get_tree().current_scene)

func on_spawn_from(player):
	if player and player.upgrade_manager:
		abilities = player.upgrade_manager.active_abilities.values()

func pool_on_spawn(payload: Dictionary) -> void:
	lifetime = _base_lifetime
	visible = true
	_spawn_trail()

func pool_on_despawn() -> void:
	direction = Vector2.ZERO
	abilities.clear()
	visible = false
	_cleanup()
	_trail = null
	
func register_pool() -> void:
	return
