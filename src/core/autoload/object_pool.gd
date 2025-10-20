extends Node

signal instance_acquired(id: String, node: Node)
signal instance_released(id: String, node: Node)
signal pool_registered(id: String)

const DEFAULT_PARENT_FALLBACK := NodePath(".")

var _pools: Dictionary = {}
var _node_to_pool: Dictionary = {}
var _auto_timers: Dictionary = {}

func _ready() -> void:
	name = "ObjectPool"
	process_mode = Node.PROCESS_MODE_INHERIT

func register_pool(id: String, scene: PackedScene, initial_size: int = 0, max_size: int = 0, auto_expand: bool = true, storage_parent: Node = null) -> void:
	if id.is_empty():
		push_error("ObjectPool.register_pool: id vazio.")
		return
	if scene == null:
		push_error("ObjectPool.register_pool: PackedScene inválido para id='%s'." % id)
		return
	if _pools.has(id):
		push_warning("ObjectPool: pool '%s' já existe, sobrescrevendo." % id)
		_clear_pool(id)

	var storage := Node.new()
	storage.name = "%s_Storage" % id
	if storage_parent == null: add_child(storage) 
	else: storage_parent.add_child(storage)

	var pool_data := {
		"scene": scene,
		"available": [],
		"in_use": [],
		"storage": storage,
		"max_size": max_size,
		"auto_expand": auto_expand
	}
	_pools[id] = pool_data
	if initial_size > 0: prewarm(id, initial_size)
	emit_signal("pool_registered", id)

func prewarm(id: String, count: int) -> void:
	var pool = _get_pool(id)
	if pool == null: return
	for i in range(count):
		var node := _instantiate_for_pool(pool)
		if node:
			_move_to_storage(node, pool)
			_set_active(node, false)
			pool.available.append(node)

func acquire(id: String, parent: Node = null, position: Vector2 = Vector2.INF, rotation: float = 0.0, payload = null) -> Node:
	var pool = _get_pool(id)
	if pool == null: return null

	var node: Node = null
	if pool.available.size() > 0:
		node = pool.available.pop_back()
	else:
		var current_total = pool.in_use.size() + pool.available.size()
		if pool.max_size <= 0 or current_total < pool.max_size or pool.auto_expand:
			node = _instantiate_for_pool(pool)
		else:
			return null

	if node == null: return null

	pool.in_use.append(node)
	_node_to_pool[node.get_instance_id()] = id

	if parent == null:
		parent = get_tree().current_scene if get_tree().current_scene != null else self
	_reparent_safe(node, parent)
	_set_active(node, true)

	if node is Node2D and position != Vector2.INF: (node as Node2D).global_position = position
	if node is Node2D: (node as Node2D).rotation = rotation

	var _payload: Dictionary = payload if payload != null else {}
	if node.has_method("pool_on_spawn"): node.pool_on_spawn(_payload)
	emit_signal("instance_acquired", id, node)
	return node

func release(node: Node) -> void:
	if node == null or not is_instance_valid(node): return
	var iid := node.get_instance_id()
	if not _node_to_pool.has(iid): return
	var id: String = _node_to_pool[iid]
	var pool = _get_pool(id)
	if pool == null:
		_node_to_pool.erase(iid); return

	var idx = pool.in_use.find(node)
	if idx != -1: pool.in_use.remove_at(idx)
	if node.has_method("pool_on_despawn"): node.pool_on_despawn()
	_cancel_auto_timer(node)
	_set_active(node, false)
	_move_to_storage(node, pool)
	pool.available.append(node)
	_node_to_pool.erase(iid)
	emit_signal("instance_released", id, node)

func release_all(id: String) -> void:
	var pool = _get_pool(id)
	if pool == null: return
	var in_use_copy = pool.in_use.duplicate()
	for n in in_use_copy: release(n)

func release_all_pools() -> void:
	for id in _pools.keys(): release_all(id)

func auto_return(node: Node, seconds: float) -> void:
	if node == null or not is_instance_valid(node): return
	var iid := node.get_instance_id()
	_cancel_auto_timer(node)
	var t := Timer.new()
	t.one_shot = true
	t.wait_time = max(0.0, seconds)
	t.timeout.connect(func():
		if is_instance_valid(node): release(node)
	)
	node.add_child(t)
	_auto_timers[iid] = t
	t.start()

func get_available_count(id: String) -> int:
	var pool = _get_pool(id)
	return pool.available.size() if pool != null else 0

func get_in_use_count(id: String) -> int:
	var pool = _get_pool(id)
	return pool.in_use.size() if pool != null else 0

func get_total_count(id: String) -> int:
	var pool = _get_pool(id)
	if pool == null: return 0
	return pool.in_use.size() + pool.available.size()

func has_pool(id: String) -> bool: return _pools.has(id)

func _get_pool(id: String):
	if not _pools.has(id):
		push_error("ObjectPool: pool '%s' não encontrado. Registre antes de usar." % id)
		return null
	return _pools[id]

func _instantiate_for_pool(pool: Dictionary) -> Node:
	var node = pool.scene.instantiate()
	_move_to_storage(node, pool)
	_set_active(node, false)
	return node

func _move_to_storage(node: Node, pool: Dictionary) -> void:
	if node.get_parent() != pool.storage:
		pool.storage.add_child(node)
		node.get_parent().remove_child(node)
		

func _reparent_safe(node: Node, new_parent: Node) -> void:
	if node.get_parent() == new_parent: return
	new_parent.add_child(node)

func _set_active(node: Node, active: bool) -> void:
	if node is CanvasItem: (node as CanvasItem).visible = active
	node.set_process(active)
	node.set_physics_process(active)

func _cancel_auto_timer(node: Node) -> void:
	var iid := node.get_instance_id()
	if _auto_timers.has(iid):
		var t: Timer = _auto_timers[iid]
		if is_instance_valid(t): t.stop(); t.queue_free()
		_auto_timers.erase(iid)

func _clear_pool(id: String) -> void:
	var pool = _pools[id]
	for n in pool.in_use: _cancel_auto_timer(n)
	for n in pool.available: _cancel_auto_timer(n)
	for n in pool.in_use: if is_instance_valid(n): n.queue_free()
	for n in pool.available: if is_instance_valid(n): n.queue_free()
	if is_instance_valid(pool.storage): pool.storage.queue_free()
	_pools.erase(id)
