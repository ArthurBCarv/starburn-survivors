# EnemyBase.gd
class_name EnemyBase
extends CharacterBody2D

@export var speed := 150
@export var base_health := 30
@export var base_damage := 10
@export var attack_cooldown := 0.5

var health: int
var damage: int
var target: Node2D
var can_attack := true

func _ready():
	# inicializa sem wave (será setado pelo spawner depois)
	health = base_health
	damage = base_damage
	add_to_group("enemies")

func _physics_process(delta):
	if target and target.is_inside_tree():
		var dir = (target.global_position - global_position).normalized()
		velocity = dir * speed
		move_and_slide()

		if can_attack and global_position.distance_to(target.global_position) < get_attack_range():
			_attack(target)

# ===== Escalamento =====
func scale_with_wave(wave: int) -> void:
	var health_multiplier := 1.2
	var damage_multiplier := 1.1
	var max_health: int
	max_health = int(base_health * pow(health_multiplier, wave - 1))
	health = max_health
	damage = int(base_damage * pow(damage_multiplier, wave - 1))

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
