extends Control

signal upgrade_selected(upgrade_id: String)

@export var upgrade_manager_path: NodePath
var upg_mgr: UpgradeManager

# Cores para diferentes tipos de upgrade
const COLORS = {
	"fire": Color(1.0, 0.3, 0.1),  # Laranja/Vermelho
	"lightning": Color(0.3, 0.6, 1.0),  # Azul elétrico
	"common": Color(0.7, 0.7, 0.7),  # Cinza
	"rare": Color(0.3, 0.8, 1.0),  # Azul claro
	"epic": Color(0.6, 0.2, 0.9),  # Roxo
}

func _ready():
	print("[UpgradeUI] Inicializando...")
	if upgrade_manager_path != NodePath():
		upg_mgr = get_node_or_null(upgrade_manager_path)
		if upg_mgr:
			print("[UpgradeUI] UpgradeManager encontrado: %s" % upg_mgr.name)
			# Conecta o sinal de upgrade_selected ao UpgradeManager
			if not upgrade_selected.is_connected(_on_upgrade_confirmed):
				upgrade_selected.connect(_on_upgrade_confirmed)
		else:
			push_error("[UpgradeUI] UpgradeManager não encontrado no path: %s" % upgrade_manager_path)
	else:
		push_error("[UpgradeUI] upgrade_manager_path não definido!")

	# Conecta ao sinal de level up do EventBus
	if EventBus and not EventBus.player_leveled_up.is_connected(_on_player_leveled_up):
		EventBus.player_leveled_up.connect(_on_player_leveled_up)
		print("[UpgradeUI] Conectado ao sinal player_leveled_up do EventBus")

	set_process_input(true)
	hide()

func _on_player_leveled_up(new_level: int):
	print("[UpgradeUI] Player subiu para o nível %d, abrindo UI de upgrade..." % new_level)
	open()

func _on_upgrade_confirmed(id: String):
	print("[UpgradeUI] Confirmando upgrade: %s" % id)
	if upg_mgr and upg_mgr.has_method("apply_upgrade"):
		upg_mgr.apply_upgrade(id)
		print("[UpgradeUI] Upgrade aplicado com sucesso!")
	else:
		push_error("[UpgradeUI] Não foi possível aplicar o upgrade!")

func open():
	print("[UpgradeUI] Abrindo UI de upgrade...")

	if not upg_mgr:
		push_error("[UpgradeUI] UpgradeManager não definido!")
		return

	_refresh_cards()
	show()
	get_tree().paused = true
	print("[UpgradeUI] UI aberta e jogo pausado")

func _refresh_cards():
	var cards_container = $Panel/VBox/Cards

	# Remove todos os filhos existentes
	for child in cards_container.get_children():
		child.queue_free()

	var opts: Array[String] = upg_mgr.get_available_options(3)
	print("[UpgradeUI] Opções disponíveis: %s" % str(opts))

	if opts.is_empty():
		var no_upgrades = Label.new()
		no_upgrades.text = "Nenhum upgrade disponível no momento"
		no_upgrades.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		cards_container.add_child(no_upgrades)
		return

	for id in opts:
		var card = _create_upgrade_card(id)
		cards_container.add_child(card)

func _create_upgrade_card(id: String) -> Control:
	# Container principal do card
	var card = PanelContainer.new()
	card.custom_minimum_size = Vector2(280, 320)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	# Estilo do card baseado no tipo
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0.1, 0.1, 0.15, 0.95)
	style_box.border_width_left = 3
	style_box.border_width_right = 3
	style_box.border_width_top = 3
	style_box.border_width_bottom = 3
	style_box.border_color = _get_upgrade_color(id)
	style_box.corner_radius_top_left = 8
	style_box.corner_radius_top_right = 8
	style_box.corner_radius_bottom_left = 8
	style_box.corner_radius_bottom_right = 8
	card.add_theme_stylebox_override("panel", style_box)

	# VBox interno
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	card.add_child(vbox)

	# Ícone/Header colorido
	var header = PanelContainer.new()
	var header_style = StyleBoxFlat.new()
	header_style.bg_color = _get_upgrade_color(id)
	header_style.corner_radius_top_left = 5
	header_style.corner_radius_top_right = 5
	header.add_theme_stylebox_override("panel", header_style)
	header.custom_minimum_size = Vector2(0, 60)

	var icon_label = Label.new()
	icon_label.text = _get_upgrade_icon(id)
	icon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	icon_label.add_theme_font_size_override("font_size", 32)
	header.add_child(icon_label)
	vbox.add_child(header)

	# Título
	var title = Label.new()
	title.text = _display_text_for(id)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 18)
	title.add_theme_color_override("font_color", _get_upgrade_color(id))
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(title)

	# Separador
	var separator = HSeparator.new()
	separator.add_theme_constant_override("separation", 2)
	vbox.add_child(separator)

	# Descrição
	var desc = Label.new()
	desc.text = _desc_for(id)
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	desc.add_theme_font_size_override("font_size", 14)
	desc.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	vbox.add_child(desc)

	# Nível atual
	var level_info = Label.new()
	var current_level = upg_mgr.get_level(id)
	var max_level = upg_mgr.max_levels.get(id, 1)
	level_info.text = "Nível: %d → %d / %d" % [current_level, current_level + 1, max_level]
	level_info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	level_info.add_theme_font_size_override("font_size", 12)
	level_info.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	vbox.add_child(level_info)

	# Botão de seleção
	var btn = Button.new()
	btn.text = "ESCOLHER"
	btn.custom_minimum_size = Vector2(0, 45)

	# Estilo do botão
	var btn_normal = StyleBoxFlat.new()
	btn_normal.bg_color = _get_upgrade_color(id) * 0.7
	btn_normal.corner_radius_top_left = 5
	btn_normal.corner_radius_top_right = 5
	btn_normal.corner_radius_bottom_left = 5
	btn_normal.corner_radius_bottom_right = 5
	btn.add_theme_stylebox_override("normal", btn_normal)

	var btn_hover = StyleBoxFlat.new()
	btn_hover.bg_color = _get_upgrade_color(id)
	btn_hover.corner_radius_top_left = 5
	btn_hover.corner_radius_top_right = 5
	btn_hover.corner_radius_bottom_left = 5
	btn_hover.corner_radius_bottom_right = 5
	btn.add_theme_stylebox_override("hover", btn_hover)

	var btn_pressed = StyleBoxFlat.new()
	btn_pressed.bg_color = _get_upgrade_color(id) * 1.2
	btn_pressed.corner_radius_top_left = 5
	btn_pressed.corner_radius_top_right = 5
	btn_pressed.corner_radius_bottom_left = 5
	btn_pressed.corner_radius_bottom_right = 5
	btn.add_theme_stylebox_override("pressed", btn_pressed)

	btn.add_theme_font_size_override("font_size", 16)
	btn.add_theme_color_override("font_color", Color.WHITE)

	# Conecta o sinal do botão
	btn.pressed.connect(func():
		print("[UpgradeUI] Upgrade selecionado: %s" % id)
		_on_upgrade_selected(id)
	)

	vbox.add_child(btn)

	return card

func _on_upgrade_selected(id: String):
	print("[UpgradeUI] Processando seleção: %s" % id)
	emit_signal("upgrade_selected", id)
	hide()
	get_tree().paused = false
	print("[UpgradeUI] UI fechada e jogo despausado")

func _get_upgrade_color(id: String) -> Color:
	if "fire" in id:
		return COLORS["fire"]
	elif "lightning" in id:
		return COLORS["lightning"]
	else:
		return COLORS["common"]

func _get_upgrade_title(id: String) -> String:
	match id:
		"fire_core":
			return "Núcleo Ígneo"
		"fire_explosion":
			return "Explosão de Fogo"
		"fire_intensity":
			return "Intensidade Ardente"
		"fire_capstone":
			return "Supernova"
		"lightning_core":
			return "Núcleo Elétrico"
		"lightning_thunder":
			return "Trovão"
		"lightning_overload":
			return "Sobrecarga"
		"lightning_capstone":
			return "Tempestade"
		_:
			return id.replace("_", " ").capitalize()

func _get_upgrade_description(id: String, level: int) -> String:
	var current_level = upg_mgr.get_level(id) if upg_mgr else 0
	var next_level = current_level + 1

	match id:
		"fire_core":
			if next_level == 1:
				return "Desbloqueia a habilidade de queimar inimigos."
			else:
				return "Nível atual: %d — já desbloqueado." % current_level
		"fire_explosion":
			return "Aumenta o dano base em %d pontos. (Nível %d)" % [5 * next_level, next_level]
		"fire_intensity":
			return "Aumenta a velocidade de tiro em %d%%. (Nível %d)" % [10 * next_level, next_level]
		"fire_capstone":
			return "Ativa o modo sobrecarga extremo: explosões maiores e dano contínuo."
		"lightning_core":
			if next_level == 1:
				return "Desbloqueia raios em cadeia que atingem múltiplos inimigos."
			else:
				return "Nível atual: %d — já desbloqueado." % current_level
		"lightning_thunder":
			return "Aumenta chance de crítico em %d%%. (Nível %d)" % [5 * next_level, next_level]
		"lightning_overload":
			return "Aumenta velocidade de movimento em %d unidades. (Nível %d)" % [50 * next_level, next_level]
		"lightning_capstone":
			return "Ativa super ataque destruidor: descargas massivas em área."
		_:
			return "Upgrade de %s (Próximo Nível: %d)" % [id.replace("_", " "), next_level]

func close() -> void:
	hide()
	get_tree().paused = false
	print("[UpgradeUI] UI fechada e jogo despausado")

func _get_upgrade_icon(id: String) -> String:
	match id:
		"fire_core": return "🔥"
		"fire_explosion": return "💥"
		"fire_intensity": return "🌋"
		"fire_capstone": return "⭐"
		"lightning_core": return "⚡"
		"lightning_thunder": return "🌩️"
		"lightning_overload": return "⚡"
		"lightning_capstone": return "✨"
		_: return "❓"

func _display_text_for(id: String) -> String:
	var lvl := upg_mgr.get_level(id) if upg_mgr else 0
	match id:
		"fire_core": return "Núcleo de Fogo"
		"fire_explosion": return "Explosão Flamejante"
		"fire_intensity": return "Intensidade Ardente"
		"fire_capstone": return "Inferno Supremo"
		"lightning_core": return "Núcleo Elétrico"
		"lightning_thunder": return "Trovão Celestial"
		"lightning_overload": return "Sobrecarga"
		"lightning_capstone": return "Tempestade Perfeita"
		_: return id

func _desc_for(id: String) -> String:
	match id:
		"fire_core":
			return "Seus tiros aplicam queimadura nos inimigos, causando dano ao longo do tempo."
		"fire_explosion":
			return "Ao acertar um inimigo, causa uma explosão que danifica inimigos próximos."
		"fire_intensity":
			return "Aumenta o dano de queimadura e o dano base dos seus ataques."
		"fire_capstone":
			return "Suas explosões agora também aplicam queimadura em todos os inimigos atingidos."
		"lightning_core":
			return "Seus tiros saltam entre inimigos próximos. Aumenta a cadência de tiro."
		"lightning_thunder":
			return "Chance de invocar um raio do céu que causa dano em área e atordoa inimigos."
		"lightning_overload":
			return "Causa dano extra contra inimigos atordoados."
		"lightning_capstone":
			return "Seus raios saltam mais uma vez e têm maior chance de invocar trovões."
		_:
			return "Descrição não disponível."

func _input(event):
	if visible and event.is_action_pressed("ui_cancel"):
		print("[UpgradeUI] ESC pressionado, fechando UI")
		hide()
		get_tree().paused = false
