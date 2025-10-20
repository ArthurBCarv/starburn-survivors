extends Node
class_name StatusEffectComponent

var burns: Array = []
var stuns: Array = []

func _process(delta):
	for b in burns:
		if owner and owner.has_method("take_damage"):
			owner.take_damage(b.dps * delta)
		b.time_left -= delta
	burns = burns.filter(func(x): return x.time_left > 0.0)

	var stunned := false
	for s in stuns:
		stunned = true
		s.time_left -= delta
	stuns = stuns.filter(func(x): return x.time_left > 0.0)

	if owner and owner.has_method("set_stunned"):
		owner.set_stunned(stunned)

func apply_burn(dps: float, duration: float):
	burns.append({ "dps": dps, "time_left": duration })

func apply_stun(duration: float):
	stuns.append({ "time_left": duration })

func is_stunned() -> bool:
	for s in stuns:
		if s.time_left > 0.0:
			return true
	return false

func clear_all():
	burns.clear()
	stuns.clear()
	if owner and owner.has_method("set_stunned"):
		owner.set_stunned(false)
