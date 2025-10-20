extends ParticleEffect

## Efeito de impacto quando projétil acerta inimigo

func _ready() -> void:
	super._ready()
	
	# Configurações de partículas
	amount = 12
	lifetime = 0.3
	explosiveness = 1.0
	randomness = 0.4
	
	# Material de processo
	var material = ParticleProcessMaterial.new()
	process_material = material
	
	# Direção radial (explosão)
	material.direction = Vector3(0, -1, 0)
	material.spread = 180.0
	material.initial_velocity_min = 80.0
	material.initial_velocity_max = 150.0
	
	# Gravidade
	material.gravity = Vector3(0, 200, 0)
	
	# Escala
	material.scale_min = 1.5
	material.scale_max = 3.0
	
	# Cor (azul elétrico/ciano)
	var gradient = Gradient.new()
	gradient.add_point(0.0, Color(0.3, 0.8, 1.0, 1.0))  # Ciano brilhante
	gradient.add_point(0.5, Color(0.1, 0.5, 1.0, 0.6))  # Azul
	gradient.add_point(1.0, Color(0.0, 0.2, 0.8, 0.0))  # Azul escuro fade
	
	var gradient_texture = GradientTexture1D.new()
	gradient_texture.gradient = gradient
	material.color_ramp = gradient_texture
