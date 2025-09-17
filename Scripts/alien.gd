class_name Alien
extends EnemyBase


func _attack(player_node: Node):
	if player_node.has_method("take_damage"):
		player_node.take_damage(damage)
	can_attack = false
	_timer_attack_reset()
func get_attack_range() -> float:
	return 25.0  # goblin ataca de mais perto

func on_death():
	queue_free()
