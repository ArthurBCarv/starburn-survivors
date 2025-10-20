extends Node
class_name ChainLightningAbility

var level := 1
var max_bounces := 1
var bounce_range := 120.0
var damage_falloff := 0.85
var extra_bounces := 0

func set_level(l: int) -> void:
	level = l
	max_bounces = 1 + (level - 1)
	bounce_range = 120.0 + (level - 1) * 20.0

func add_extra_bounce(n: int) -> void:
	extra_bounces += n

func _bolt_vfx(a: Vector2, b: Vector2):
	if ObjectPool.has_pool("fx_lightning_bolt"):
		var fx = ObjectPool.acquire("fx_lightning_bolt", get_tree().current_scene)
		if fx and fx.has_method("from_to"):
			fx.from_to(a, b)
			ObjectPool.auto_return(fx, 0.12)
	else:
		var bolt = preload("res://src/vfx/lightning_bolt.tscn").instantiate()
		get_tree().current_scene.add_child(bolt)
		bolt.call("from_to", a, b)

func on_projectile_hit(projectile, enemy) -> void:
	_chain_from(enemy, projectile.damage, max_bounces + extra_bounces, {})

func _chain_from(src_enemy, damage: float, bounces_left: int, visited: Dictionary) -> void:
	if bounces_left <= 0 or not is_instance_valid(src_enemy): return
	visited[src_enemy.get_instance_id()] = true
	var next = _find_next_target(src_enemy.global_position, bounce_range, visited)
	if next:
		_bolt_vfx(src_enemy.global_position, next.global_position)
		if next.has_method("take_damage"): next.take_damage(damage * damage_falloff)
		_chain_from(next, damage * damage_falloff, bounces_left - 1, visited)

func _find_next_target(from: Vector2, range: float, visited: Dictionary):
	var results = get_tree().get_nodes_in_group("enemies")
	var candidates: Array = []
	for e in results:
		if not is_instance_valid(e): continue
		if visited.has(e.get_instance_id()): continue
		if e.global_position.distance_to(from) <= range:
			candidates.append(e)
	if candidates.is_empty(): return null
	candidates.sort_custom(func(a, b): return a.global_position.distance_squared_to(from) < b.global_position.distance_squared_to(from))
	return candidates[0]
