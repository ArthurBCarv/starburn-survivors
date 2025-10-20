extends Node

## Script de teste para verificar todos os sistemas

func _ready() -> void:
	print("\n=== TESTE DE SISTEMAS ===\n")
	
	# Testa VFXManager
	print("1. Testando VFXManager...")
	if VFXManager:
		print("  ✅ VFXManager encontrado")
		# Testa spawn de efeito
		VFXManager.spawn_effect("muzzle_flash", Vector2(100, 100))
		print("  ✅ Teste de spawn executado")
	else:
		print("  ❌ VFXManager não encontrado")
	
	# Testa EventBus
	print("\n2. Testando EventBus...")
	if EventBus:
		print("  ✅ EventBus encontrado")
		# Testa emissão de sinal
		EventBus.enemy_died.emit(null, 10)
		print("  ✅ Teste de sinal executado")
	else:
		print("  ❌ EventBus não encontrado")
	
	# Testa ObjectPool
	print("\n3. Testando ObjectPool...")
	if ObjectPool:
		print("  ✅ ObjectPool encontrado")
		
		# Verifica se a cena existe primeiro
		var bullet_path = "res://src/weapons/projectiles/bullet/bullet.tscn"
		if ResourceLoader.exists(bullet_path):
			print("  ✅ Bullet scene existe")
			
			# Carrega a cena
			var test_scene = load(bullet_path)
			if test_scene and test_scene is PackedScene:
				print("  ✅ Bullet scene carregada como PackedScene")
				
				# Registra pool
				ObjectPool.register_pool("test_bullet", test_scene, 5)
				print("  ✅ Pool registrado")
				
				# Testa get/return
				var obj = ObjectPool.get_object("test_bullet")
				if obj:
					print("  ✅ Objeto obtido do pool")
					ObjectPool.return_object("test_bullet", obj)
					print("  ✅ Objeto retornado ao pool")
				else:
					print("  ❌ Falha ao obter objeto do pool")
			else:
				print("  ❌ Falha ao carregar bullet scene como PackedScene")
				print("  📝 Tipo da cena: %s" % str(type_string(typeof(test_scene))))
		else:
			print("  ❌ Bullet scene não existe no caminho: %s" % bullet_path)
	else:
		print("  ❌ ObjectPool não encontrado")
	
	print("\n=== TESTE CONCLUÍDO ===\n")
	
	# Carrega cena principal após 2 segundos
	await get_tree().create_timer(2.0).timeout
	print("Carregando cena principal...")
	get_tree().change_scene_to_file("res://src/core/game_scene.tscn")
