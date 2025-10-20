extends ParticleEffect

## Efeito de flash do cano da arma ao disparar

func _ready() -> void:
	super._ready()
	
	# Configurações de partículas
	amount = 8
	lifetime = 0.2
	explosiveness = 1.0
	randomness = 0.3
	
	# Material de processo
	var material = ParticleProcessMaterial.new()
	process_material = material
	
	# Direção e spread
	material.direction = Vector3(1, 0, 0)
	material.spread = 30.0
	material.initial_velocity_min = 100.0
	material.initial_velocity_max = 200.0
	
	# Gravidade e damping
	material.gravity = Vector3.ZERO
	material.linear_accel_min = -50.0
	material.linear_accel_max = -100.0
	
	# Escala
	material.scale_min = 2.0
	material.scale_max = 4.0
	
	# Cor (laranja/amarelo brilhante)
	var gradient = Gradient.new()
	gradient.add_point(0.0, Color(1.0, 0.9, 0.3, 1.0))  # Amarelo brilhante
	gradient.add_point(0.5, Color(1.0, 0.5, 0.1, 0.8))  # Laranja
	gradient.add_point(1.0, Color(0.8, 0.2, 0.0, 0.0))  # Vermelho fade
	
	var gradient_texture = GradientTexture1D.new()
	gradient_texture.gradient = gradient
	material.color_ramp = gradient_texture
