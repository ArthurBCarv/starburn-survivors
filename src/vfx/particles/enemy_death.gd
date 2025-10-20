extends ParticleEffect

## Efeito de morte de inimigo

var death_color: Color = Color.RED

func _ready() -> void:
	super._ready()
	
	# Configurações de partículas
	amount = 20
	lifetime = 0.8
	explosiveness = 0.8
	randomness = 0.4
	
	# Material de processo
	var material = ParticleProcessMaterial.new()
	process_material = material
	
	# Direção radial
	material.direction = Vector3(0, -1, 0)
	material.spread = 180.0
	material.initial_velocity_min = 100.0
	material.initial_velocity_max = 250.0
	
	# Gravidade
	material.gravity = Vector3(0, 300, 0)
	material.damping_min = 30.0
	material.damping_max = 60.0
	
	# Escala
	material.scale_min = 2.0
	material.scale_max = 5.0
	
	_update_color()

func set_color(color: Color) -> void:
	death_color = color
	_update_color()

func _update_color() -> void:
	if not process_material:
		return
	
	var material = process_material as ParticleProcessMaterial
	if not material:
		return
	
	# Cria gradiente baseado na cor fornecida
	var gradient = Gradient.new()
	gradient.add_point(0.0, death_color.lightened(0.3))
	gradient.add_point(0.5, death_color)
	gradient.add_point(1.0, Color(death_color.r * 0.3, death_color.g * 0.3, death_color.b * 0.3, 0.0))
	
	var gradient_texture = GradientTexture1D.new()
	gradient_texture.gradient = gradient
	material.color_ramp = gradient_texture
