# EnemyBase.gd
class_name EnemyBase
extends CharacterBody2D

@export var speed := 150
@export var max_health := 30
@export var damage := 10
@export var attack_cooldown := 0.5

var health: int
var target: Node2D
var can_attack := true

func _ready():
	health = max_health
	add_to_group("enemies")

func _physics_process(delta):
	if target and target.is_inside_tree():
		# movimento em direção ao player
		var dir = (target.global_position - global_position).normalized()
		velocity = dir * speed
		move_and_slide()

		# ataque se dentro do raio definido
		if can_attack and global_position.distance_to(target.global_position) < get_attack_range():
			_attack(target)

# ===== Métodos base =====
func take_damage(amount: int):
	health -= amount
	if health <= 0:
		on_death()
		
func _timer_attack_reset():
	var t = get_tree().create_timer(attack_cooldown)
	t.timeout.connect(func():
		can_attack = true
	)

func _attack(player_node: Node) -> void:
	push_error("_attack não implementado em " + str(self))

func get_attack_range() -> float:
	return 20.0  # valor padrão, pode ser sobrescrito

func on_death():
	queue_free()
