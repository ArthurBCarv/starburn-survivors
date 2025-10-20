extends Node2D

@export var radius := 48.0
@export var damage := 10.0
@export var apply_burn := false
@export var burn_dps := 2.0
@export var burn_duration := 1.5

func _apply_effect():
	var cs: CollisionShape2D = $Area2D/CollisionShape2D
	var circle := cs.shape as CircleShape2D
	circle.radius = radius
	await get_tree().process_frame
	for body in $Area2D.get_overlapping_bodies():
		if body.is_in_group("enemies"):
			if body.has_method("take_damage"): body.take_damage(damage)
			if apply_burn:
				var sec = body.get_node_or_null("StatusEffectComponent")
				if sec: sec.apply_burn(burn_dps, burn_duration)

func pool_on_spawn(payload: Dictionary) -> void:
	radius = payload.get("radius", radius)
	damage = payload.get("damage", damage)
	apply_burn = payload.get("apply_burn", false)
	burn_dps = payload.get("burn_dps", burn_dps)
	burn_duration = payload.get("burn_duration", burn_duration)
	$Particles.emitting = true
	_apply_effect()

func pool_on_despawn() -> void:
	$Particles.emitting = false

func _ready():
	if get_parent() and get_parent().get_name().ends_with("_Storage"): return
	$Particles.emitting = true
	_apply_effect()
	await get_tree().create_timer(0.5).timeout
	queue_free()
