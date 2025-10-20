extends ParticleEffect

## Efeito de explosão

func _ready() -> void:
	super._ready()
	
	# Configurações de partículas
	amount = 30
	lifetime = 0.6
	explosiveness = 0.9
	randomness = 0.3
	
	# Material de processo
	var material = ParticleProcessMaterial.new()
	process_material = material
	
	# Direção radial (explosão em todas direções)
	material.direction = Vector3(0, -1, 0)
	material.spread = 180.0
	material.initial_velocity_min = 150.0
	material.initial_velocity_max = 300.0
	
	# Gravidade e damping
	material.gravity = Vector3(0, 100, 0)
	material.damping_min = 50.0
	material.damping_max = 100.0
	
	# Escala
	material.scale_min = 3.0
	material.scale_max = 6.0
	
	# Cor (laranja/vermelho fogo)
	var gradient = Gradient.new()
	gradient.add_point(0.0, Color(1.0, 1.0, 0.8, 1.0))  # Branco quente
	gradient.add_point(0.3, Color(1.0, 0.6, 0.1, 1.0))  # Laranja
	gradient.add_point(0.7, Color(1.0, 0.2, 0.0, 0.6))  # Vermelho
	gradient.add_point(1.0, Color(0.3, 0.0, 0.0, 0.0))  # Vermelho escuro fade
	
	var gradient_texture = GradientTexture1D.new()
	gradient_texture.gradient = gradient
	material.color_ramp = gradient_texture
