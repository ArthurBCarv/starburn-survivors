extends Node
class_name PlayerLevel

@export var level: int = 1
@export var xp: int = 0
@export var base_xp_to_next: int = 20
@export var xp_growth: float = 1.3

signal level_up(new_level: int)
signal xp_changed(current_xp: int, xp_to_next: int)

var xp_to_next_level: int

func _ready() -> void:
	xp_to_next_level = xp_to_next()
	# Emite estado inicial do XP
	_emit_xp_changed()

func add_xp(amount: int) -> void:
	if amount <= 0:
		return
	
	xp += amount
	_emit_xp_changed()
	
	# Verifica se subiu de nível (pode subir múltiplos níveis de uma vez)
	while xp >= xp_to_next_level:
		xp -= xp_to_next_level
		level += 1
		xp_to_next_level = xp_to_next()
		_on_level_up()
		_emit_xp_changed()

func xp_to_next() -> int:
	return int(round(base_xp_to_next * pow(xp_growth, max(0, level - 1))))

func _on_level_up() -> void:
	print("[PlayerLevel] Level UP! Novo nível: %d" % level)

	# Emite sinal local (para UpgradeManager)
	emit_signal("level_up", level)

	# Emite sinal global (para UI de upgrade)
	if EventBus:
		EventBus.player_leveled_up.emit(level)

func _emit_xp_changed() -> void:
	emit_signal("xp_changed", xp, xp_to_next_level)

	# Emite sinal global para UI
	if EventBus:
		EventBus.player_xp_changed.emit(xp, xp_to_next_level, level)

func get_xp_percent() -> float:
	return float(xp) / float(xp_to_next_level) if xp_to_next_level > 0 else 0.0
