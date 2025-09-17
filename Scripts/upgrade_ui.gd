extends Control

signal upgrade_selected(upgrade_type)

func _ready():
	$ButtonUpgrade1.pressed.connect(func(): _select("damage"))
	$ButtonUpgrade2.pressed.connect(func(): _select("fire_rate"))
	$ButtonUpgrade3.pressed.connect(func(): _select("range"))

func _select(tipo):
	emit_signal("upgrade_selected", tipo)
	hide()
	get_tree().paused = false
