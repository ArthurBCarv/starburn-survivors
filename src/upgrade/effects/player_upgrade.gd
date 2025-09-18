class_name PlayerUpgrade
var speed_bonus := 0
var damage_bonus := 0
var fire_rate_bonus := 0
var detection_radius_bonus := 0

func apply_to(player):
	player.speed += speed_bonus
	player.bullet_damage += damage_bonus
	player.fire_rate = max(player.fire_rate - fire_rate_bonus, 0.01)  # fire rate diminui o delay
	player.detection_radius += detection_radius_bonus
