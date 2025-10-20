extends Node2D

@export var radius := 64.0
@export var damage := 15.0
@export var stun_duration := 0.2

func _apply_effect():
	var cs: CollisionShape2D = $Area2D/CollisionShape2D
	var circle := cs.shape as CircleShape2D
	circle.radius = radius
	await get_tree().process_frame
	for body in $Area2D.get_overlapping_bodies():
		if body.is_in_group("enemies"):
			if body.has_method("take_damage"): body.take_damage(damage)
			var sec = body.get_node_or_null("StatusEffectComponent")
			if sec: sec.apply_stun(stun_duration)

func pool_on_spawn(payload: Dictionary) -> void:
	radius = payload.get("radius", radius)
	damage = payload.get("damage", damage)
	stun_duration = payload.get("stun_duration", stun_duration)
	_apply_effect()

func pool_on_despawn() -> void: pass

func _ready():
	if get_parent() and get_parent().get_name().ends_with("_Storage"): return
	_apply_effect()
	await get_tree().create_timer(0.2).timeout
	queue_free()
