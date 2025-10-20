# Guia de Implementação Rápida - Starburn Survivors

## 🚀 Setup Inicial

### 1. Configurar Cena Principal

Crie uma cena principal com a seguinte estrutura:

```
Game (Node2D)
├── Player (CharacterBody2D) [player.tscn]
│   ├── Sprite2D
│   ├── CollisionShape2D
│   ├── Camera2D
│   ├── PlayerLevel (Node)
│   └── UpgradeManager (Node)
├── EnemySpawner (Node)
└── UI (CanvasLayer)
    ├── HUD
    └── UpgradeUI
```

### 2. Configurar Player

No player.tscn:
- Adicione o script `res://src/player/player.gd`
- Configure o grupo "player"
- Adicione Camera2D como filho
- Configure arena_rect para os limites do mapa

### 3. Configurar EnemySpawner

```gdscript
# No Inspector do EnemySpawner
@export var enemy_scenes: Array[PackedScene] = [
    preload("res://src/enemy/alien/alien1.tscn")
]
@export var boss_scenes: Array[PackedScene] = [
    preload("res://src/enemy/alien/boss1.tscn")
]
```

### 4. Criar Inimigo Básico

```gdscript
# alien1.gd
extends EnemyBase

func _ready():
    super._ready()
    base_health = 30.0
    base_damage = 10.0
    speed = 150.0
    xp_reward = 5
    death_particle_color = Color.RED

func _attack(player_node: Node) -> void:
    if not can_attack:
        return
    
    can_attack = false
    _timer_attack_reset()
    
    if player_node.has_method("take_damage"):
        player_node.take_damage(damage)
```

### 5. Criar Boss

```gdscript
# boss1.gd
extends BossEnemy

func _ready():
    super._ready()
    base_health = 100.0
    base_damage = 20.0
    speed = 100.0
    xp_reward = 50
    
    boss_health_multiplier = 5.0
    boss_damage_multiplier = 2.0
    boss_size_multiplier = 2.5
    death_particle_color = Color.PURPLE
```

## 🎮 Sistemas Prontos para Uso

### Sistema de Partículas

Já funciona automaticamente! Os efeitos são spawnados quando:
- Player dispara → Muzzle Flash
- Projétil acerta → Hit Impact
- Inimigo morre → Enemy Death
- Explosões → Explosion Effect

### Sistema de Dano

Adicione DamageComponent aos inimigos (já feito automaticamente no EnemyBase):

```gdscript
# Customizar no _ready() do inimigo
if damage_component:
    damage_component.show_damage_numbers = true
    damage_component.flash_on_damage = true
    damage_component.flash_color = Color.RED
```

### Sistema de Spawn

Configure no Inspector do EnemySpawner:
- **Spawn Margin**: 100 (distância fora da câmera)
- **Min Spawn Distance**: 150 (distância mínima do player)
- **Wave Interval**: 30 (segundos entre waves)
- **Enemies Per Wave Base**: 10
- **Enemies Per Wave Growth**: 1.5
- **Boss Wave Interval**: 5 (boss a cada 5 waves)

## 🎯 Testando o Jogo

### Checklist de Teste

1. ✅ Player se move com WASD/Setas
2. ✅ Player atira automaticamente no inimigo mais próximo
3. ✅ Efeito de muzzle flash aparece ao disparar
4. ✅ Projétil tem rastro de plasma
5. ✅ Impacto mostra partículas azuis
6. ✅ Inimigos aparecem fora da câmera
7. ✅ Números de dano aparecem ao acertar
8. ✅ Inimigos piscam em vermelho ao receber dano
9. ✅ Morte de inimigo mostra partículas
10. ✅ XP é ganho ao matar inimigos
11. ✅ Level up abre menu de upgrades
12. ✅ Boss aparece na wave 5, 10, 15...
13. ✅ Boss é maior e mais forte

## 🔧 Configurações Recomendadas

### ObjectPool (já configurado)

Configure pools para objetos frequentes:

```gdscript
# No _ready() da cena principal ou GameManager
ObjectPool.register_pool("bullet", preload("res://src/weapons/projectiles/bullet/bullet.tscn"), 50)
ObjectPool.register_pool("enemy1", preload("res://src/enemy/alien/alien1.tscn"), 30)
```

### Camera2D

Configure no player:
```gdscript
# No Camera2D do player
enabled = true
zoom = Vector2(1.0, 1.0)  # Ajuste conforme necessário
position_smoothing_enabled = true
position_smoothing_speed = 5.0
```

## 🎨 Customizando Efeitos Visuais

### Mudar Cores de Partículas

```gdscript
# No script do inimigo
death_particle_color = Color.GREEN  # Alien verde
death_particle_color = Color.BLUE   # Alien azul
death_particle_color = Color.PURPLE # Boss
```

### Criar Novo Efeito de Partícula

1. Crie novo script em `src/vfx/particles/`:

```gdscript
extends ParticleEffect

func _ready() -> void:
    super._ready()
    
    amount = 20
    lifetime = 0.5
    explosiveness = 0.8
    
    var material = ParticleProcessMaterial.new()
    process_material = material
    
    # Configure material...
```

2. Crie cena .tscn correspondente
3. Adicione ao VFXManager:

```gdscript
# Em vfx_manager.gd
const MEU_EFEITO = preload("res://src/vfx/particles/meu_efeito.tscn")

static func spawn_meu_efeito(pos: Vector2) -> void:
    _spawn_effect(MEU_EFEITO, pos)
```

## 🐛 Troubleshooting

### Partículas não aparecem
- Verifique se VFXManager está nos autoloads
- Verifique se as cenas .tscn existem
- Verifique console para erros de preload

### Inimigos não spawnam
- Verifique se enemy_scenes está configurado no Inspector
- Verifique se player está no grupo "player"
- Verifique se Camera2D está ativa

### Dano não funciona
- Verifique se inimigo tem DamageComponent
- Verifique se projétil tem collision layer/mask corretos
- Verifique se inimigo está no grupo "enemies"

### Boss não escala
- Verifique se boss herda de BossEnemy
- Verifique se scale_with_wave() é chamado
- Verifique multiplicadores no Inspector

## 📊 Balanceamento Sugerido

### Inimigos Básicos
- HP: 30-50
- Dano: 10-15
- Velocidade: 100-200
- XP: 5-10

### Inimigos Médios
- HP: 80-120
- Dano: 20-30
- Velocidade: 80-150
- XP: 15-25

### Boss
- HP Base: 200-500
- Dano Base: 30-50
- Velocidade: 60-100
- XP: 100-200
- Multiplicadores: 3-5x

### Player
- HP: 100
- Velocidade: 600
- Dano Base: 10
- Fire Rate: 0.05 (20 tiros/seg)
- Detection Radius: 250

## 🎯 Próximos Passos

1. **Adicionar mais tipos de inimigos**
   - Copie alien1.tscn
   - Mude sprite e stats
   - Adicione ao enemy_spawner

2. **Criar mais upgrades**
   - Adicione em `src/upgrades/abilities/`
   - Registre no UpgradeManager
   - Adicione descrições na UI

3. **Melhorar feedback visual**
   - Adicione screen shake
   - Adicione hit stop
   - Adicione mais partículas

4. **Sistema de power-ups**
   - Crie cena de power-up
   - Spawne ao matar inimigos
   - Adicione efeitos temporários

5. **Menu e Game Over**
   - Crie cena de menu
   - Crie tela de game over
   - Adicione estatísticas
