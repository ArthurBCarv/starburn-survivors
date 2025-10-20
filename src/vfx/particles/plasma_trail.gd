extends GPUParticles2D

## Rastro de plasma para projéteis

var _lifetime := 0.5

func _ready() -> void:
	# Configurações de partículas
	amount = 20
	lifetime = 0.3
	emitting = true
	
	# Material de processo
	var material = ParticleProcessMaterial.new()
	process_material = material
	
	# Direção (para trás do projétil)
	material.direction = Vector3(-1, 0, 0)
	material.spread = 15.0
	material.initial_velocity_min = 20.0
	material.initial_velocity_max = 50.0
	
	# Gravidade zero (espaço)
	material.gravity = Vector3.ZERO
	material.damping_min = 20.0
	material.damping_max = 40.0
	
	# Escala
	material.scale_min = 1.0
	material.scale_max = 2.0
	
	# Cor (plasma azul/ciano)
	var gradient = Gradient.new()
	gradient.add_point(0.0, Color(0.5, 0.9, 1.0, 0.8))  # Ciano brilhante
	gradient.add_point(0.5, Color(0.2, 0.6, 1.0, 0.5))  # Azul
	gradient.add_point(1.0, Color(0.0, 0.3, 0.8, 0.0))  # Azul escuro fade
	
	var gradient_texture = GradientTexture1D.new()
	gradient_texture.gradient = gradient
	material.color_ramp = gradient_texture

func _process(delta: float) -> void:
	_lifetime -= delta
	if _lifetime <= 0.0:
		queue_free()
