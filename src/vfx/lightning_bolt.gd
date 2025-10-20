extends Line2D

func from_to(a: Vector2, b: Vector2) -> void:
	var pts: PackedVector2Array = []
	var steps := 12
	var dir := b - a
	var ort := dir.orthogonal().normalized()
	for i in steps + 1:
		var t := float(i) / steps
		var p := a.lerp(b, t)
		if i > 0 and i < steps: p += ort * randf_range(-6.0, 6.0)
		pts.append(p)
	points = pts

func pool_on_spawn(payload: Dictionary) -> void:
	var a: Vector2 = payload.get("a", Vector2.ZERO)
	var b: Vector2 = payload.get("b", Vector2.ZERO)
	from_to(a, b)

func _ready():
	if get_parent() and get_parent().get_name().ends_with("_Storage"): return
	await get_tree().create_timer(0.08).timeout
	queue_free()
