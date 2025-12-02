extends Node
class_name BossFactory

static func create_boss_from_alien(alien_scene: PackedScene, wave: int = 1) -> Node:
	var boss = alien_scene.instantiate()
	
	var scale_factor = 1.0 + (wave * 0.3)
	var health_mult = 5.0 + (wave * 1.5)
	var damage_mult = 2.5 + (wave * 0.5)
	var speed_mult = 0.9
	
	_apply_boss_stats(boss, health_mult, damage_mult, speed_mult, wave)
	_scale_boss_visual(boss, scale_factor)
	
	boss.name = "AlienBoss_Wave" + str(wave)
	
	return boss

static func _apply_boss_stats(node: Node, health_mult: float, damage_mult: float, speed_mult: float, wave: int) -> void:
	var props = node.get_property_list()
	var prop_names = []
	for p in props:
		prop_names.append(p.name)
	
	if "max_health" in prop_names:
		var base_health = node.get("max_health")
		node.max_health = float(base_health) * health_mult
		if "health" in prop_names:
			node.set("health", node.get("max_health"))
	
	if "base_health" in prop_names:
		var base_h = node.get("base_health")
		node.base_health = float(base_h) * health_mult
		if "health" in prop_names:
			node.set("health", node.base_health)
	
	if "damage" in prop_names:
		node.damage = float(node.get("damage")) * damage_mult
	
	if "base_damage" in prop_names:
		node.base_damage = float(node.get("base_damage")) * damage_mult
	
	if "speed" in prop_names:
		node.speed = float(node.get("speed")) * speed_mult
	
	if "xp_reward" in prop_names:
		node.xp_reward = int(node.get("xp_reward")) * (5 + wave)

static func _scale_boss_visual(node: Node, scale_factor: float) -> void:
	var scale_vec = Vector2(scale_factor, scale_factor)
	
	if node is CanvasItem:
		node.scale = node.scale * scale_vec
	
	for child in node.get_children():
		if child is CollisionShape2D:
			var s = child.shape
			if s:
				_scale_shape(s, scale_vec)

static func _scale_shape(shape: Object, scale_mult: Vector2) -> void:
	if not shape:
		return
	
	var prop_list = shape.get_property_list()
	var prop_names = []
	for p in prop_list:
		prop_names.append(p.name)
	
	if "extents" in prop_names:
		var v = shape.get("extents")
		shape.set("extents", Vector2(v.x * scale_mult.x, v.y * scale_mult.y))
		return
	if "size" in prop_names:
		var v2 = shape.get("size")
		shape.set("size", Vector2(v2.x * scale_mult.x, v2.y * scale_mult.y))
		return
	
	if "radius" in prop_names:
		var r = float(shape.get("radius"))
		shape.set("radius", r * max(scale_mult.x, scale_mult.y))
		return
	
	if "height" in prop_names and "radius" in prop_names:
		var h = float(shape.get("height"))
		var rad = float(shape.get("radius"))
		shape.set("height", h * scale_mult.y)
		shape.set("radius", rad * max(scale_mult.x, scale_mult.y))
		return
