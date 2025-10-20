extends RefCounted
class_name UpgradeBuilder

var upgrade := PlayerUpgradeData.new()

func add_speed(amount: float) -> UpgradeBuilder:
	upgrade.speed_bonus += amount; return self
func add_damage(amount: float) -> UpgradeBuilder:
	upgrade.damage_bonus += amount; return self
func add_fire_rate(amount: float) -> UpgradeBuilder:
	upgrade.fire_rate_bonus += amount; return self
func add_range(amount: float) -> UpgradeBuilder:
	upgrade.detection_radius_bonus += amount; return self

func build() -> PlayerUpgradeData: return upgrade
