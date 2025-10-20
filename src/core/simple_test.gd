extends Node

func _ready() -> void:
	print("=== TESTE SIMPLES OBJECTPOOL ===")
	
	# Verifica se ObjectPool existe
	if not ObjectPool:
		print("❌ ObjectPool não encontrado!")
		return
	
	print("✅ ObjectPool encontrado")
	
	# Tenta carregar a cena bullet
	var bullet_scene = preload("res://src/weapons/projectiles/bullet/bullet.tscn")
	print("✅ Bullet scene precarregada: %s" % str(bullet_scene))
	print("📝 Tipo: %s" % str(type_string(typeof(bullet_scene))))
	
	# Tenta registrar o pool
	print("Registrando pool...")
	ObjectPool.register_pool("test", bullet_scene, 1)
	print("✅ Pool registrado com sucesso!")
	
	# Tenta obter um objeto
	var obj = ObjectPool.get_object("test")
	if obj:
		print("✅ Objeto obtido: %s" % str(obj))
	else:
		print("❌ Falha ao obter objeto")
	
	print("=== TESTE CONCLUÍDO ===")
	
	# Aguarda e vai para o jogo
	await get_tree().create_timer(3.0).timeout
	get_tree().change_scene_to_file("res://src/core/game_scene.tscn")
