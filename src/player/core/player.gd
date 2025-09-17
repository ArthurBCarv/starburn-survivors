extends CharacterBody2D

@export var speed := 600
@export var bullet_scene: PackedScene
@export var fire_rate := 0.05
@export var max_health := 100
@export var detection_radius := 250.0
@export var arena_rect := Rect2(Vector2.ZERO, Vector2(2000, 2000))  # limite da arena
@export var bullet_damage := 40


var health := max_health
var last_shot_time := 0.0
var move_dir := Vector2.RIGHT

func _process(delta):
	_move(delta)
	_auto_shoot(delta)

func _move(delta):
	var input_vector = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if input_vector != Vector2.ZERO:
		move_dir = input_vector.normalized()
	velocity = input_vector * speed
	move_and_slide()

	# Limita ao retângulo da arena
	position.x = clamp(position.x, arena_rect.position.x, arena_rect.position.x + arena_rect.size.x)
	position.y = clamp(position.y, arena_rect.position.y, arena_rect.position.y + arena_rect.size.y)



func _auto_shoot(delta):
	var enemies = get_tree().get_nodes_in_group("enemies")
	var closest_enemy: Node2D = null
	var closest_dist := INF
	for e in enemies:
		if e and e.is_inside_tree():
			var dist = global_position.distance_to(e.global_position)
			if dist < closest_dist and dist <= detection_radius:
				closest_dist = dist
				closest_enemy = e
	
	if closest_enemy and (Time.get_ticks_msec() - last_shot_time) / 1000.0 > fire_rate:
		var dir = (closest_enemy.global_position - global_position).normalized()
		var bullet = bullet_scene.instantiate()
		bullet.global_position = global_position
		bullet.direction = dir
		get_parent().add_child(bullet)
		bullet.damage = bullet_damage
		last_shot_time = Time.get_ticks_msec()

func take_damage(amount):
	health -= amount
	if health <= 0:
		queue_free()  # game over pode ser chamado no Game.gd
		
func upgrade_speed():
	speed += 50
	print("Velocidade aumentada para ", speed)

func upgrade_damage():
	bullet_damage += 5
	print("Dano da arma aumentado para ", bullet_damage)

func upgrade_range():
	detection_radius += 50
	print("Alcance aumentado para ", detection_radius)
