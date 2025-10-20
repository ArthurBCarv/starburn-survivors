extends Control

enum upgrade{FIRERATE, SPEED, DAMAGE, } 
#TODO: aqui deve coolocar outros upgrades por enquanto só vou deixar o mais basico possivel para fins de teste

signal upgrade_selected(upgrade)

func _ready():
	return
func _select(tipo):
	emit_signal("upgrade_selected", tipo)
	hide()
	get_tree().paused = false
