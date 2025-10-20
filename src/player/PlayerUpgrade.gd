# PlayerUpgradeData.gd - Classe para representar os upgrades do player

class_name PlayerUpgradeData

var speed_bonus := 0.0
var damage_bonus := 0.0
var fire_rate_bonus := 0.0
var detection_radius_bonus := 0.0

func _init():
	pass

func build() -> PlayerUpgradeData:
	return self