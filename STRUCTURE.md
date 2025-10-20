# Estrutura do Projeto - Starburn Survivors

## 📁 Organização de Pastas

```
src/
├── core/                          # Sistemas centrais do jogo
│   ├── autoload/                  # Singletons globais
│   │   ├── event_bus.gd          # Sistema de eventos global
│   │   ├── game_manager.gd       # Gerenciador de jogo
│   │   └── object_pool.gd        # Sistema de pooling de objetos
│   └── components/                # Componentes reutilizáveis
│       └── damage_component.gd   # Componente de dano com feedback visual
│
├── player/                        # Tudo relacionado ao jogador
│   ├── abilities/                 # Habilidades do player (vazio - pronto para expansão)
│   ├── player.gd                 # Script principal do player
│   ├── player.tscn               # Cena do player
│   ├── player_level.gd           # Sistema de XP e level
│   ├── player_stats.gd           # Stats do player
│   └── upgrade_manager.gd        # Gerenciador de upgrades do player
│
├── enemy/                         # Sistema de inimigos
│   ├── alien/                     # Tipos de aliens
│   ├── spawner/                   # Sistema de spawn
│   │   └── enemy_spawner.gd      # Spawner com waves e boss
│   ├── bossFactory/               # Factory de bosses
│   │   ├── boss_factory.gd       # Cria bosses escaláveis
│   │   └── boss_factory.tscn
│   ├── enemyBase.gd              # Classe base de inimigos
│   ├── boss_enemy.gd             # Classe base de bosses escaláveis
│   └── status_effect_component.gd # Efeitos de status (burn, stun)
│
├── weapons/                       # Sistema de armas
│   ├── projectiles/               # Projéteis
│   │   └── bullet/
│   │       ├── bullet.gd         # Projétil com efeitos visuais
│   │       └── bullet.tscn
│   ├── weapon_base/              # Base de armas
│   ├── beam_weapon.gd            # Arma de feixe
│   └── projectile_weapon.gd      # Arma de projéteis
│
├── upgrades/                      # Sistema de upgrades
│   ├── abilities/                 # Habilidades de upgrade
│   │   ├── fire_burn_ability.gd
│   │   ├── fire_explosion_ability.gd
│   │   ├── chain_lightning_ability.gd
│   │   ├── thunder_strike_ability.gd
│   │   └── overload_ability.gd
│   ├── builder/                   # Builder de upgrades
│   ├── effects/                   # Efeitos de upgrades
│   ├── modules/                   # Módulos de upgrade (pronto para expansão)
│   ├── upgrade.gd
│   ├── upgrade_applier.gd
│   ├── upgrade_database.gd
│   └── upgrade_manager.gd
│
├── vfx/                           # Efeitos visuais
│   ├── particles/                 # Sistema de partículas
│   │   ├── particle_effect.gd    # Classe base de partículas
│   │   ├── muzzle_flash.gd       # Flash do disparo
│   │   ├── hit_impact.gd         # Impacto de projétil
│   │   ├── explosion.gd          # Explosão
│   │   ├── enemy_death.gd        # Morte de inimigo
│   │   ├── plasma_trail.gd       # Rastro de plasma
│   │   └── *.tscn                # Cenas de partículas
│   ├── shaders/                   # Shaders customizados
│   ├── vfx_manager.gd            # Gerenciador de VFX (autoload)
│   ├── fire_explosion.gd
│   ├── lightning_bolt.gd
│   └── lightning_strike.gd
│
├── ui/                            # Interface do usuário
│   ├── hud/                       # HUD do jogo
│   └── upgrade_ui/                # UI de seleção de upgrades
│       ├── upgrade.gd
│       └── upgrade.tscn
│
└── utils/                         # Utilitários gerais
```

## 🎯 Sistemas Implementados

### ✅ Sistema de Partículas (VFX)
- **ParticleEffect**: Classe base reutilizável com pooling
- **VFXManager**: Gerenciador centralizado (autoload)
- **Efeitos disponíveis**:
  - Muzzle Flash (disparo)
  - Hit Impact (impacto)
  - Explosion (explosão)
  - Enemy Death (morte customizável)
  - Plasma Trail (rastro de projétil)

### ✅ Sistema de Dano
- **DamageComponent**: Componente modular com:
  - Números de dano flutuantes
  - Flash visual ao receber dano
  - Sinais de dano e morte
  - Integração com sprites

### ✅ Sistema de Spawn
- **EnemySpawner**: Spawn inteligente com:
  - Spawn fora da câmera
  - Sistema de waves progressivas
  - Boss waves automáticas (a cada 5 waves)
  - Escalamento de dificuldade
  - Integração com EventBus

### ✅ Sistema de Boss
- **BossEnemy**: Boss escalável com:
  - Multiplicadores de HP, dano e tamanho
  - Escala visual automática por wave
  - Stats crescentes por wave
  - XP multiplicado
  - Efeitos visuais especiais

- **BossFactory**: Factory para criar bosses:
  - Converte inimigos normais em bosses
  - Cria bosses genéricos customizados
  - Escalamento automático

## 🔧 Como Usar

### Spawnar Efeitos Visuais
```gdscript
# Disparo
VFXManager.spawn_muzzle_flash(position)

# Impacto
VFXManager.spawn_hit_impact(position)

# Explosão
VFXManager.spawn_explosion(position, scale_multiplier)

# Morte de inimigo
VFXManager.spawn_enemy_death(position, Color.RED)

# Rastro de plasma
var trail = VFXManager.spawn_plasma_trail(position, parent_node)
```

### Usar DamageComponent
```gdscript
# Adicionar ao inimigo
var damage_comp = DamageComponent.new()
damage_comp.max_health = 100
damage_comp.show_damage_numbers = true
add_child(damage_comp)

# Aplicar dano
damage_comp.take_damage(25)

# Conectar sinais
damage_comp.died.connect(_on_died)
```

### Configurar EnemySpawner
```gdscript
# Na cena principal
var spawner = EnemySpawner.new()
spawner.enemy_scenes = [preload("res://enemy1.tscn"), preload("res://enemy2.tscn")]
spawner.boss_scenes = [preload("res://boss1.tscn")]
spawner.spawn_margin = 100.0
spawner.wave_interval = 30.0
add_child(spawner)
```

### Criar Boss Escalável
```gdscript
# Herdar de BossEnemy
extends BossEnemy

func _ready():
    super._ready()
    boss_health_multiplier = 5.0
    boss_size_multiplier = 3.0
```

## 🎨 Próximas Expansões Sugeridas

1. **Módulos de Upgrade** (`src/upgrades/modules/`)
   - plasma_module.gd
   - laser_module.gd
   - missile_module.gd
   - nano_module.gd

2. **Habilidades do Player** (`src/player/abilities/`)
   - dash_ability.gd
   - shield_ability.gd
   - time_slow_ability.gd

3. **Tipos de Inimigos** (`src/enemy/alien/`)
   - Diferentes comportamentos
   - Padrões de ataque variados

4. **Shaders** (`src/vfx/shaders/`)
   - Shield shader
   - Hit flash shader
   - Distortion effects

## 📝 Convenções de Código

- **Classes**: PascalCase (ex: `EnemyBase`, `VFXManager`)
- **Arquivos**: snake_case (ex: `enemy_base.gd`, `vfx_manager.gd`)
- **Variáveis**: snake_case (ex: `current_health`, `max_damage`)
- **Constantes**: UPPER_SNAKE_CASE (ex: `MAX_ENEMIES`, `SPAWN_RATE`)
- **Sinais**: snake_case (ex: `enemy_died`, `wave_started`)

## 🚀 Autoloads Configurados

1. **ObjectPool** - Sistema de pooling
2. **EventBus** - Comunicação global
3. **VFXManager** - Gerenciador de efeitos visuais
