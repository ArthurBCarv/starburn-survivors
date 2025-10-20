extends Node
class_name ThunderStrikeAbility

var level := 1
var base_chance := 0.02
var bonus_chance := 0.0
var aoe_radius := 64.0
var damage := 15.0
var stun_duration := 0.2

func set_level(l: int) -> void:
	level = l
	damage = 15.0 + (level - 1) * 5.0
	aoe_radius = 64.0 + (level - 1) * 16.0
	stun_duration = 0.2 + (level - 1) * 0.1

func _strike_vfx(pos: Vector2):
	if ObjectPool.has_pool("fx_lightning_strike"):
		var fx = ObjectPool.acquire("fx_lightning_strike", get_tree().current_scene, pos, 0,{
			"radius": aoe_radius, "damage": damage, "stun_duration": stun_duration
		})
		if fx: ObjectPool.auto_return(fx, 0.3)
	else:
		var s = preload("res://src/vfx/lightning_strike.tscn").instantiate()
		s.global_position = pos
		s.set("radius", aoe_radius)
		s.set("damage", damage)
		s.set("stun_duration", stun_duration)
		get_tree().current_scene.add_child(s)

func on_projectile_hit(projectile, enemy) -> void:
	if not is_instance_valid(enemy): return
	var chance := base_chance + bonus_chance
	if randf() < chance:
		_strike_vfx(enemy.global_position)
