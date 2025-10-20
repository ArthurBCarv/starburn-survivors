extends Node
class_name FireExplosionAbility

var level := 1
var radius := 48.0
var damage := 8.0
var apply_burn_on_aoe: bool = false
var burn_dps_on_aoe := 2.0
var burn_duration_on_aoe := 1.5

func _spawn_explosion(pos: Vector2):
	if ObjectPool.has_pool("fx_fire_explosion"):
		var fx = ObjectPool.acquire("fx_fire_explosion", get_tree().current_scene, pos, 0, {
			"radius": radius, "damage": damage,
			"apply_burn": apply_burn_on_aoe,
			"burn_dps": burn_dps_on_aoe, "burn_duration": burn_duration_on_aoe
		})
		if fx: ObjectPool.auto_return(fx, 0.6)
	else:
		var e = preload("res://src/vfx/fire_explosion.tscn").instantiate()
		e.global_position = pos
		e.set("radius", radius); e.set("damage", damage)
		e.set("apply_burn", apply_burn_on_aoe)
		e.set("burn_dps", burn_dps_on_aoe)
		e.set("burn_duration", burn_duration_on_aoe)
		get_tree().current_scene.add_child(e)

func set_level(l: int) -> void:
	level = l
	radius = 48.0 + (level - 1) * 16.0
	damage = 8.0 + (level - 1) * 4.0

func on_projectile_hit(projectile, enemy) -> void:
	if not is_instance_valid(projectile): return
	_spawn_explosion(projectile.global_position)
