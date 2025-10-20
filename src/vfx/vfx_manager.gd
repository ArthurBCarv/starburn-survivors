extends Node

# Singleton instance
static var _instance: VFXManager

func _enter_tree() -> void:
	_instance = self

func _exit_tree() -> void:
	_instance = null

## Spawna efeito de disparo
static func spawn_muzzle_flash(pos: Vector2, parent: Node = null) -> void:
	if not _instance:
		push_warning("[VFXManager] Instance not found")
		return
	
	var scene = load("res://src/vfx/particles/muzzle_flash.tscn")
	if scene:
		_instance._spawn_effect_internal(scene, pos, parent)

## Spawna efeito de impacto
static func spawn_hit_impact(pos: Vector2, parent: Node = null) -> void:
	if not _instance:
		push_warning("[VFXManager] Instance not found")
		return
		
	var scene = load("res://src/vfx/particles/hit_impact.tscn")
	if scene:
		_instance._spawn_effect_internal(scene, pos, parent)

## Spawna explosão
static func spawn_explosion(pos: Vector2, scale_mult: float = 1.0, parent: Node = null) -> void:
	if not _instance:
		push_warning("[VFXManager] Instance not found")
		return
		
	var scene = load("res://src/vfx/particles/explosion.tscn")
	if scene:
		var effect = _instance._spawn_effect_internal(scene, pos, parent)
		if effect:
			effect.scale = Vector2.ONE * scale_mult

## Spawna efeito de morte de inimigo
static func spawn_enemy_death(pos: Vector2, color: Color = Color.RED, parent: Node = null) -> void:
	if not _instance:
		push_warning("[VFXManager] Instance not found")
		return
		
	var scene = load("res://src/vfx/particles/enemy_death.tscn")
	if scene:
		var effect = _instance._spawn_effect_internal(scene, pos, parent)
		if effect and effect.has_method("set_color"):
			effect.set_color(color)

## Spawna rastro de plasma
static func spawn_plasma_trail(pos: Vector2, parent: Node = null) -> Node:
	if not _instance:
		push_warning("[VFXManager] Instance not found")
		return null
		
	var scene = load("res://src/vfx/particles/plasma_trail.tscn")
	if scene:
		return _instance._spawn_effect_internal(scene, pos, parent)
	return null

## Método interno para spawnar efeitos
func _spawn_effect_internal(scene: PackedScene, pos: Vector2, parent: Node = null) -> Node:
	if not scene:
		push_warning("[VFXManager] Scene not found")
		return null
	
	var effect = scene.instantiate()
	if not effect:
		return null
	
	# Determina o parent
	var target_parent = parent
	if not target_parent:
		target_parent = get_tree().current_scene
	
	if not target_parent:
		push_warning("[VFXManager] No valid parent found")
		effect.queue_free()
		return null
	
	# Adiciona ao parent
	target_parent.add_child(effect)
	
	# Define posição
	if effect is Node2D:
		effect.global_position = pos
	
	return effect
