# 💡 Dicas de Desenvolvimento - Expandindo o Sistema VFX

## 🎨 Adicionando Novos Upgrades VFX

### 1. Criar Nova Habilidade

#### Estrutura Básica (src/upgrades/abilities/nova_habilidade.gd)
```gdscript
extends Node
class_name NovaHabilidade

var level := 1
var damage := 10.0
var cooldown := 1.0

func set_level(l: int) -> void:
    level = l
    damage = 10.0 + (level - 1) * 5.0

func on_projectile_hit(projectile, enemy) -> void:
    if not is_instance_valid(enemy): return
    # Sua lógica aqui
    _spawn_effect(enemy.global_position)

func _spawn_effect(pos: Vector2):
    # Spawnar efeito visual
    if ObjectPool.has_pool("fx_nova"):
        var fx = ObjectPool.acquire("fx_nova", get_tree().current_scene, pos)
        if fx: ObjectPool.auto_return(fx, 0.5)
    else:
        var effect = preload("res://src/vfx/nova_effect.tscn").instantiate()
        effect.global_position = pos
        get_tree().current_scene.add_child(effect)
```

### 2. Criar Efeito Visual

#### Estrutura Básica (src/vfx/nova_effect.gd)
```gdscript
extends Node2D

@export var radius := 50.0
@export var damage := 15.0
@export var duration := 0.5

func _ready():
    if get_parent() and get_parent().get_name().ends_with("_Storage"): 
        return
    
    $Particles.emitting = true
    _apply_effect()
    await get_tree().create_timer(duration).timeout
    queue_free()

func _apply_effect():
    var cs: CollisionShape2D = $Area2D/CollisionShape2D
    var circle := cs.shape as CircleShape2D
    circle.radius = radius
    
    await get_tree().process_frame
    
    for body in $Area2D.get_overlapping_bodies():
        if body.is_in_group("enemies"):
            if body.has_method("take_damage"):
                body.take_damage(damage)

func pool_on_spawn(payload: Dictionary) -> void:
    radius = payload.get("radius", radius)
    damage = payload.get("damage", damage)
    $Particles.emitting = true
    _apply_effect()

func pool_on_despawn() -> void:
    $Particles.emitting = false
```

### 3. Registrar no UpgradeManager

#### Adicionar em upgrade_manager.gd:
```gdscript
# No dicionário ABILITIES:
const ABILITIES := {
    "fire_burn": preload("res://src/upgrades/abilities/fire_burn_ability.gd"),
    "nova": preload("res://src/upgrades/abilities/nova_habilidade.gd"),  # NOVO
    # ... outros
}

# No dicionário levels:
var levels := {
    "nova_core": 0,  # NOVO
    # ... outros
}

# No dicionário max_levels:
var max_levels := {
    "nova_core": 1,  # NOVO
    # ... outros
}

# Na função _prereq_met:
func _prereq_met(id: String) -> bool:
    match id:
        "nova_core":
            return true  # Sempre disponível
        # ... outros

# Na função _apply_effects:
func _apply_effects(id: String, level: int) -> void:
    match id:
        "nova_core":
            enable_ability("nova", 1)
            var b := UpgradeBuilder.new()
            b.add_damage(5.0)
            player.apply_upgrade(b.build())
        # ... outros
```

### 4. Adicionar na UI de Upgrade

#### Adicionar em upgrade.gd:
```gdscript
# Na função _get_upgrade_icon:
func _get_upgrade_icon(id: String) -> String:
    match id:
        "nova_core": return "✨"  # NOVO
        # ... outros

# Na função _display_text_for:
func _display_text_for(id: String) -> String:
    match id:
        "nova_core": return "Núcleo Nova"  # NOVO
        # ... outros

# Na função _desc_for:
func _desc_for(id: String) -> String:
    match id:
        "nova_core":
            return "Seus tiros criam uma explosão estelar que causa dano massivo."
        # ... outros

# Na função _get_upgrade_color:
func _get_upgrade_color(id: String) -> Color:
    if "nova" in id:
        return Color(1.0, 0.8, 0.0)  # Dourado
    # ... outros
```

## 🎨 Criando Efeitos Visuais Melhores

### Usando Shaders

#### Shader de Brilho (src/vfx/shaders/glow.gdshader)
```glsl
shader_type canvas_item;

uniform vec4 glow_color : source_color = vec4(1.0, 0.5, 0.0, 1.0);
uniform float glow_intensity : hint_range(0.0, 2.0) = 1.0;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    COLOR = tex + glow_color * glow_intensity * tex.a;
}
```

### Usando Partículas

#### Sistema de Partículas Avançado
```gdscript
# No _ready() do efeito:
var particles = $GPUParticles2D
particles.amount = 50
particles.lifetime = 0.5
particles.explosiveness = 0.8
particles.emitting = true

# Configurar material de partículas
var material = ParticleProcessMaterial.new()
material.direction = Vector3(0, -1, 0)
material.spread = 180.0
material.initial_velocity_min = 100.0
material.initial_velocity_max = 200.0
material.gravity = Vector3(0, 98, 0)
particles.process_material = material
```

## 🔊 Adicionando Sons

### 1. Criar AudioManager (src/core/autoload/audio_manager.gd)
```gdscript
extends Node

var sounds := {
    "fire_burn": preload("res://assets/sounds/fire_burn.ogg"),
    "explosion": preload("res://assets/sounds/explosion.ogg"),
    "lightning": preload("res://assets/sounds/lightning.ogg"),
}

func play_sound(sound_name: String, position: Vector2 = Vector2.ZERO):
    if not sounds.has(sound_name):
        return
    
    var player = AudioStreamPlayer2D.new()
    player.stream = sounds[sound_name]
    player.global_position = position
    get_tree().current_scene.add_child(player)
    player.play()
    
    await player.finished
    player.queue_free()
```

### 2. Usar nos Efeitos
```gdscript
# Na habilidade:
func _spawn_effect(pos: Vector2):
    AudioManager.play_sound("explosion", pos)
    # ... resto do código
```

## 📊 Balanceamento

### Fórmulas Úteis

#### Escalonamento de Dano
```gdscript
# Linear
damage = base_damage + (level - 1) * increment

# Exponencial
damage = base_damage * pow(multiplier, level - 1)

# Logarítmico
damage = base_damage + log(level) * scale_factor
```

#### Escalonamento de Cooldown
```gdscript
# Diminuição linear
cooldown = max(min_cooldown, base_cooldown - (level - 1) * reduction)

# Diminuição exponencial
cooldown = max(min_cooldown, base_cooldown * pow(0.9, level - 1))
```

#### Escalonamento de Área
```gdscript
# Linear
radius = base_radius + (level - 1) * increment

# Área linear (raio cresce mais devagar)
radius = sqrt(base_radius * base_radius + (level - 1) * area_increment)
```

## 🎯 Padrões de Design

### Padrão Observer (Eventos)
```gdscript
# Emitir evento
EventBus.effect_applied.emit(target, "burn", {"dps": 5.0, "duration": 2.0})

# Escutar evento
EventBus.effect_applied.connect(_on_effect_applied)

func _on_effect_applied(target: Node, effect_type: String, data: Dictionary):
    # Reagir ao efeito
    pass
```

### Padrão Object Pool
```gdscript
# Registrar pool
ObjectPool.register_pool("fx_explosion", explosion_scene, 10)

# Usar pool
var fx = ObjectPool.acquire("fx_explosion", parent, position)
ObjectPool.auto_return(fx, 0.5)
```

### Padrão Builder
```gdscript
# Construir upgrade complexo
var upgrade = UpgradeBuilder.new()
    .add_damage(10.0)
    .add_fire_rate(0.1)
    .add_speed(50.0)
    .build()

player.apply_upgrade(upgrade)
```

## 🐛 Debug e Testes

### Console de Debug
```gdscript
# Adicionar no player.gd:
func _input(event):
    if event is InputEventKey and event.pressed:
        match event.keycode:
            KEY_1: # Dar upgrade específico
                upgrade_manager.apply_upgrade("fire_core")
            KEY_2:
                upgrade_manager.apply_upgrade("lightning_core")
            KEY_3: # Spawnar inimigos
                for i in 10:
                    _spawn_test_enemy()
            KEY_4: # Limpar inimigos
                get_tree().call_group("enemies", "queue_free")
            KEY_5: # Heal completo
                health = max_health
                EventBus.player_health_changed.emit(health, max_health)
```

### Visualização de Debug
```gdscript
# Mostrar raio de detecção
func _draw():
    if OS.is_debug_build():
        draw_circle(Vector2.ZERO, detection_radius, Color(1, 0, 0, 0.2))
```

## 📚 Recursos Úteis

### Documentação Godot
- [Particles](https://docs.godotengine.org/en/stable/tutorials/2d/particle_systems_2d.html)
- [Shaders](https://docs.godotengine.org/en/stable/tutorials/shaders/index.html)
- [Audio](https://docs.godotengine.org/en/stable/tutorials/audio/index.html)

### Ferramentas
- [Aseprite](https://www.aseprite.org/) - Pixel art
- [GIMP](https://www.gimp.org/) - Edição de imagens
- [Audacity](https://www.audacityteam.org/) - Edição de áudio
- [Shadertoy](https://www.shadertoy.com/) - Inspiração para shaders

## 🎓 Boas Práticas

1. **Sempre use Object Pools** para efeitos que spawnam frequentemente
2. **Separe lógica de visual** (habilidade vs efeito visual)
3. **Use sinais** para comunicação entre sistemas
4. **Documente seus upgrades** (nome, descrição, valores)
5. **Teste combinações** de upgrades
6. **Balance progressivamente** (comece fraco, ajuste depois)
7. **Use constantes** para valores mágicos
8. **Prefira composição** sobre herança
9. **Mantenha efeitos curtos** (0.3-0.8 segundos)
10. **Otimize partículas** (menos é mais)

---

**Boa sorte expandindo seu jogo! 🚀**
