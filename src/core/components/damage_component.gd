extends Node
class_name DamageComponent

## Componente para gerenciar dano com feedback visual

signal damage_taken(amount: float, current_health: float, max_health: float)
signal died()

@export var max_health: float = 100.0
@export var show_damage_numbers := true
@export var flash_on_damage := true
@export var flash_duration := 0.1
@export var flash_color := Color.RED


var current_health: float
var is_dead := false

func reset_state() -> void:
	current_health = max_health
	is_dead = false

@onready var owner_node: Node2D = get_parent()

func _ready() -> void:
	current_health = max_health

func take_damage(amount: float, source: Node = null) -> void:
	if is_dead or amount <= 0:
		return
	
	current_health -= amount
	current_health = max(0, current_health)
	
	damage_taken.emit(amount, current_health, max_health)
	
	# Feedback visual
	if show_damage_numbers:
		_spawn_damage_number(amount)
	
	if flash_on_damage and owner_node:
		_flash_damage()
	
	# Verifica morte
	if current_health <= 0 and not is_dead:
		is_dead = true
		died.emit()

func heal(amount: float) -> void:
	if is_dead:
		return
	
	current_health = min(max_health, current_health + amount)
	damage_taken.emit(-amount, current_health, max_health)

func get_health_percent() -> float:
	return current_health / max_health if max_health > 0 else 0.0

func _spawn_damage_number(amount: float) -> void:
	if not owner_node:
		return
	
	var damage_label = Label.new()
	damage_label.text = str(int(amount))
	damage_label.add_theme_font_size_override("font_size", 20)
	damage_label.add_theme_color_override("font_color", Color.WHITE)
	damage_label.add_theme_color_override("font_outline_color", Color.BLACK)
	damage_label.add_theme_constant_override("outline_size", 2)
	damage_label.z_index = 100
	
	owner_node.add_child(damage_label)
	damage_label.global_position = owner_node.global_position + Vector2(randf_range(-20, 20), -30)
	
	# Animação do número
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(damage_label, "position:y", damage_label.position.y - 50, 0.8)
	tween.tween_property(damage_label, "modulate:a", 0.0, 0.8)
	tween.finished.connect(damage_label.queue_free)

func _flash_damage() -> void:
	var sprite = _find_sprite(owner_node)
	if not sprite:
		return
	
	var original_modulate = sprite.modulate
	sprite.modulate = flash_color
	
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", original_modulate, flash_duration)

func _find_sprite(node: Node) -> Node:
	# Procura por Sprite2D ou AnimatedSprite2D
	if node is Sprite2D or node is AnimatedSprite2D:
		return node
	
	for child in node.get_children():
		if child is Sprite2D or child is AnimatedSprite2D:
			return child
		var result = _find_sprite(child)
		if result:
			return result
	
	return null
