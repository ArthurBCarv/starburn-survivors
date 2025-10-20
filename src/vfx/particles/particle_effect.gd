extends GPUParticles2D
class_name ParticleEffect

## Sistema base para efeitos de partículas com auto-destruição e pooling

@export var auto_destroy := true
@export var destroy_delay := 2.0

var _timer: Timer

func _ready() -> void:
	one_shot = true
	emitting = false
	
	if auto_destroy:
		finished.connect(_on_finished)

func play_effect(pos: Vector2 = global_position) -> void:
	global_position = pos
	restart()
	emitting = true

func _on_finished() -> void:
	if auto_destroy:
		if _timer == null:
			_timer = Timer.new()
			_timer.one_shot = true
			_timer.timeout.connect(_destroy)
			add_child(_timer)
		_timer.start(destroy_delay)

func _destroy() -> void:
	queue_free()

## Métodos para pooling
func pool_on_spawn(payload: Dictionary) -> void:
	if payload.has("position"):
		global_position = payload.position
	play_effect()

func pool_on_despawn() -> void:
	emitting = false
