extends Node
class_name BossFactory

# Multiplicadores padrão para boss (ajuste conforme quiser)
const DEFAULT_HEALTH_MULT := 3.5
const DEFAULT_DAMAGE_MULT := 2.0
const DEFAULT_SPEED_MULT := 0.85
const DEFAULT_ATTACK_COOLDOWN_MULT := 0.9
const DEFAULT_SCALE_MULT := Vector2(1.9, 1.9)

# API pública: aceita PackedScene, Node (instância) ou caminho String
static func make_boss(enemy_source) -> Node:
	"""
	Cria e retorna um nó que representa o boss baseado em `enemy_source`.
	`enemy_source` pode ser:
	 - PackedScene (vai instanciar)
	 - Node (instância já criada) -> será duplicada
	 - String (path) -> carrega como PackedScene
	"""
	var base_instance: Node = null

	# Resolver o tipo de entrada
	if typeof(enemy_source) == TYPE_OBJECT and enemy_source is PackedScene:
		base_instance = enemy_source.instantiate()
	elif typeof(enemy_source) == TYPE_STRING:
		var ps = load(enemy_source)
		if ps and ps is PackedScene:
			base_instance = ps.instantiate()
		else:
			push_error("makeBoss: path informado não é uma PackedScene: " + str(enemy_source))
			return null
	elif typeof(enemy_source) == TYPE_OBJECT and enemy_source is Node:
		# duplicar a instância passada (deep-ish copy)
		# duplicate() costuma funcionar para réplicas; se houver recursos externos, talvez precise de ajustes
		base_instance = enemy_source.duplicate()
	else:
		push_error("makeBoss: Tipo de enemy_source não suportado: " + str(typeof(enemy_source)))
		return null

	# Aplica modificadores de atributos (se estiverem presentes)
	_apply_boss_stats(base_instance, DEFAULT_HEALTH_MULT, DEFAULT_DAMAGE_MULT, DEFAULT_SPEED_MULT, DEFAULT_ATTACK_COOLDOWN_MULT)

	# Aumenta a escala visual e ajusta shapes das colisões (se existirem)
	_scale_node_recursive(base_instance, DEFAULT_SCALE_MULT)

	# Nome visual para debug
	base_instance.name = str(base_instance.name) + "_BOSS"

	return base_instance


# ----- helpers -----
static func _apply_boss_stats(node: Node, health_mult: float, damage_mult: float, speed_mult: float, attack_cooldown_mult: float) -> void:
	# usa get_property_list para checar se as propriedades existem e setá-las de forma segura
	var props = node.get_property_list()
	var prop_names = []
	for p in props:
		prop_names.append(p.name)

	if "max_health" in prop_names:
		node.max_health = float(node.get("max_health")) * health_mult
		# se existir health também, atualiza para full health
		if "health" in prop_names:
			node.set("health", node.get("max_health"))

	if "damage" in prop_names:
		node.damage = float(node.get("damage")) * damage_mult

	if "speed" in prop_names:
		node.speed = float(node.get("speed")) * speed_mult

	if "attack_cooldown" in prop_names:
		# reduzir o cooldown (ataques mais rápidos)
		node.attack_cooldown = float(node.get("attack_cooldown")) * attack_cooldown_mult

	# Se o nó tiver filhos que contenham propriedades personalizadas (ex.: pontos, loot),
	# não mexemos neles automaticamente — você pode estender aqui conforme necessidade.


static func _scale_node_recursive(node: Node, scale_mult: Vector2) -> void:
	# Escala nó visual (CanvasItem) e ajusta colisões (CollisionShape2D)
	if node is CanvasItem:
		# multiplicar a escala atual
		node.scale = node.scale * scale_mult

	# Ajustar CollisionShape2D shapes que não escalam automaticamente
	if node is CollisionShape2D:
		var s = node.shape
		if s:
			_scale_shape(s, scale_mult)

	# Recurse
	for child in node.get_children():
		if child is Node:
			_scale_node_recursive(child, scale_mult)


static func _scale_shape(shape: Object, scale_mult: Vector2) -> void:
	# Faz um best-effort para tipos comuns de Shape2D:
	# tenta ler propriedades conhecidas e multiplicar adequadamente.
	if not shape:
		return

	var prop_list = shape.get_property_list()
	var prop_names = []
	for p in prop_list:
		prop_names.append(p.name)

	# extents / size (Vector2)
	if "extents" in prop_names:
		var v = shape.get("extents")
		shape.set("extents", Vector2(v.x * scale_mult.x, v.y * scale_mult.y))
		return
	if "size" in prop_names:
		var v2 = shape.get("size")
		shape.set("size", Vector2(v2.x * scale_mult.x, v2.y * scale_mult.y))
		return

	# radius (CircleShape2D)
	if "radius" in prop_names:
		var r = float(shape.get("radius"))
		shape.set("radius", r * max(scale_mult.x, scale_mult.y))
		return

	# height / radius (Capsule)
	if "height" in prop_names and "radius" in prop_names:
		var h = float(shape.get("height"))
		var rad = float(shape.get("radius"))
		shape.set("height", h * scale_mult.y)
		shape.set("radius", rad * max(scale_mult.x, scale_mult.y))
		return

	# points / vertices (Polygon / ConvexPolygon)
	if "points" in prop_names:
		var pts = shape.get("points")
		for i in range(pts.size()):
			pts[i] = Vector2(pts[i].x * scale_mult.x, pts[i].y * scale_mult.y)
		shape.set("points", pts)
		return

	# fallback: tenta multiplicar propriedades numéricas/vec2 conhecidas
	# (se nada for reconhecido, o shape pode precisar de ajuste manual)
