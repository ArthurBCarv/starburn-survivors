extends Area2D

@export var speed := 400
@export var damage := 10
@export var lifetime := 2.0 # segundos de vida padrão do projétil
@export var perfuration := 0;
var direction := Vector2.ZERO

func _process(delta):
	# mover projétil
	position += direction * speed * delta

	# reduzir tempo de vida
	lifetime -= delta
	if lifetime <= 0:
		queue_free()

func _on_body_entered(body):
	if body.is_in_group("enemies") and body.has_method("take_damage"):
		body.take_damage(damage)
		if perfuration <= 0:
			queue_free()
