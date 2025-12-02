extends CanvasLayer
class_name HUD

var wave_index: int = 1
var boss_wave: bool = false
var alive: int = 0
var target_count: int = 0


func _ready():
	print("[HUD] Inicializando...")
	
	# Conecta aos eventos globais
	if EventBus:
		EventBus.wave_started.connect(_on_wave_started)
		EventBus.wave_cleared.connect(_on_wave_cleared)
		EventBus.enemy_spawned.connect(func(_n): _update_alive(+1))
		EventBus.enemy_died.connect(func(_n, _xp): _update_alive(-1))
		EventBus.boss_spawned.connect(func(_n): _set_state("Boss!"))
		EventBus.boss_died.connect(func(_n, _xp): _set_state("Boss derrotado"))
		EventBus.player_health_changed.connect(_on_player_health_changed)
		EventBus.player_xp_changed.connect(_on_player_xp_changed)
		print("[HUD] Eventos conectados")
	else:
		push_error("[HUD] EventBus não encontrado!")

	# Estado inicial
	_update_wave_label()
	_update_enemies_label()


func _on_wave_started(index: int, is_boss_wave: bool, target: int) -> void:
	wave_index = index
	boss_wave = is_boss_wave
	target_count = target
	alive = 0
	_set_state("Boss wave" if is_boss_wave else "Wave")
	_update_wave_label()
	_update_enemies_label()


func _on_wave_cleared(index: int) -> void:
	if index == wave_index:
		_set_state("Wave limpa!")


func _update_alive(delta: int) -> void:
	alive = max(0, alive + delta)
	_update_enemies_label()


func _update_wave_label() -> void:
	var label = get_node_or_null("Root/TopBar/WaveLabel")
	if label:
		label.text = "Wave: %d" % wave_index


func _set_state(text: String) -> void:
	var label = get_node_or_null("Root/TopBar/StateLabel")
	if label:
		label.text = "Estado: %s" % text


func _update_enemies_label() -> void:
	var label = get_node_or_null("Root/TopBar/EnemiesLabel")
	if label:
		label.text = "Inimigos: %d / %d" % [alive, target_count]


func _on_player_health_changed(current: float, max_value: float) -> void:
	var hp_bar = get_node_or_null("Root/TopBar/HPBox/HPBar")
	if hp_bar:
		hp_bar.max_value = max_value
		hp_bar.value = clamp(current, 0.0, max_value)


func _on_player_xp_changed(xp: int, xp_to_next: int, level: int) -> void:
	$Root/TopBar/XPLabel.text = "LV %d — XP: %d / %d" % [level, xp, xp_to_next]
	
	print("[HUD] XP atualizado: %d/%d (Level %d)" % [xp, xp_to_next, level])
