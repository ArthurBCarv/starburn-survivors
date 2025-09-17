extends Area2D

@export var speed := 400
@export var damage := 10
var direction := Vector2.ZERO


func _process(delta):
	position += direction * speed * delta

func _on_body_entered(body):
	if body.is_in_group("enemies") and body.has_method("take_damage"):
		body.take_damage(damage)
		queue_free()
