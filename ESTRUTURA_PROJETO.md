# 📁 Estrutura Completa do Projeto - Starburn Survivors

## 🗂️ Visão Geral

```
starburn-survivors/
├── addons/                          # Plugins do Godot
│   ├── ai_assistant_hub/           # Plugin de assistente AI
│   ├── script-ide/                 # Plugin de IDE
│   └── Todo_Manager/               # Plugin de gerenciamento de TODOs
├── assets/                          # Assets do jogo (vazio por enquanto)
├── levels/                          # Cenas de níveis
│   └── arena/
│       ├── Game.gd                 # Script principal do jogo
│       └── Game.tscn               # Cena principal (arena)
├── src/                            # Código fonte
│   ├── core/                       # Sistemas centrais
│   │   └── autoload/              # Scripts autoload (singletons)
│   │       ├── event_bus.gd       # Sistema de eventos global
│   │       ├── object_pool.gd     # Sistema de pooling de objetos
│   │       └── vfx_manager.gd     # Gerenciador de efeitos visuais
│   ├── enemy/                      # Inimigos
│   │   ├── alien/
│   │   │   ├── alien.gd
│   │   │   └── alien.tscn
│   │   ├── boss_alien/
│   │   │   ├── boss_alien.gd
│   │   │   └── boss_alien.tscn
│   │   ├── spawner/
│   │   │   ├── enemy_spawner.gd   # Sistema de spawn de inimigos
│   │   │   └── enemy_spawner.tscn
│   │   ├── damage_component.gd     # Componente de dano
│   │   ├── enemyBase.gd           # Classe base de inimigos
│   │   └── status_effect_component.gd  # Componente de efeitos de status
│   ├── player/                     # Jogador
│   │   ├── player.gd              # Script do jogador
│   │   ├── player.tscn            # Cena do jogador
│   │   ├── player_level.gd        # Sistema de level/XP
│   │   └── upgrade_manager.gd     # Gerenciador de upgrades
│   ├── ui/                         # Interface do usuário
│   │   ├── hud/
│   │   │   ├── hud.gd
│   │   │   └── hud.tscn
│   │   └── upgrade_ui/
│   │       ├── upgrade.gd         # UI de seleção de upgrades
│   │       └── upgrade.tscn
│   ├── upgrades/                   # Sistema de upgrades
│   │   ├── abilities/             # Habilidades VFX
│   │   │   ├── chain_lightning_ability.gd
│   │   │   ├── fire_burn_ability.gd
│   │   │   ├── fire_explosion_ability.gd
│   │   │   ├── overload_ability.gd
│   │   │   └── thunder_strike_ability.gd
│   │   └── builder/
│   │       ├── builder_upgrade.gd  # Builder pattern para upgrades
│   │       └── PlayerUpgrade.gd    # Dados de upgrade
│   ├── vfx/                        # Efeitos visuais
│   │   ├── particles/             # Sistemas de partículas
│   │   │   ├── enemy_death.tscn
│   │   │   ├── hit_impact.tscn
│   │   │   ├── muzzle_flash.tscn
│   │   │   └── plasma_trail.tscn
│   │   ├── fire_explosion.gd
│   │   ├── fire_explosion.tscn
│   │   ├── lightning_bolt.gd
│   │   ├── lightning_bolt.tscn
│   │   ├── lightning_strike.gd
│   │   ├── lightning_strike.tscn
│   │   └── vfx_manager.gd         # Gerenciador de VFX
│   └── weapons/                    # Armas e projéteis
│       └── projectiles/
│           └── bullet/
│               ├── bullet.gd
│               └── bullet.tscn
├── CHECKLIST_TESTE.md              # Checklist de testes
├── CONTRIBUTING.md                 # Guia de contribuição
├── CORREÇÕES_VFX.md               # Documentação das correções
├── DICAS_DESENVOLVIMENTO.md        # Dicas para desenvolvedores
├── export_presets.cfg              # Configurações de exportação
├── GUIA_TESTE_RAPIDO.md           # Guia rápido de teste
├── icon.svg                        # Ícone do projeto
├── IMPLEMENTATION_SUMMARY.md       # Resumo da implementação
├── LICENSE                         # Licença do projeto
├── project.godot                   # Arquivo de projeto Godot
├── README.md                       # README principal
├── RESUMO_CORREÇÕES.md            # Resumo das correções
└── ESTRUTURA_PROJETO.md           # Este arquivo
```

## 🎯 Componentes Principais

### 1. Autoloads (Singletons)
Configurados em `project.godot`:

| Nome | Caminho | Função |
|------|---------|--------|
| EventBus | src/core/autoload/event_bus.gd | Sistema de eventos global |
| ObjectPool | src/core/autoload/object_pool.gd | Pooling de objetos |
| VFXManager | src/vfx/vfx_manager.gd | Gerenciamento de VFX |

### 2. Sistemas de Jogo

#### Sistema de Combate
- **Player** (`src/player/player.gd`)
  - Movimento (WASD)
  - Tiro automático
  - Sistema de vida
  - Aplicação de upgrades

- **Enemies** (`src/enemy/enemyBase.gd`)
  - IA básica (perseguir player)
  - Sistema de vida
  - Componentes de dano e status
  - Recompensa de XP

- **Projectiles** (`src/weapons/projectiles/bullet/bullet.gd`)
  - Movimento
  - Dano
  - Perfuração
  - Habilidades VFX

#### Sistema de Progressão
- **PlayerLevel** (`src/player/player_level.gd`)
  - XP e níveis
  - Curva de progressão
  - Sinais de level up

- **UpgradeManager** (`src/player/upgrade_manager.gd`)
  - Gerenciamento de upgrades
  - Pré-requisitos
  - Ativação de habilidades
  - Aplicação de efeitos

#### Sistema de UI
- **HUD** (`src/ui/hud/hud.gd`)
  - Barra de vida
  - Barra de XP
  - Contador de waves
  - Contador de inimigos

- **UpgradeUI** (`src/ui/upgrade_ui/upgrade.gd`)
  - Seleção de upgrades
  - Cards visuais
  - Pausa do jogo
  - Descrições

#### Sistema de VFX
- **VFXManager** (`src/vfx/vfx_manager.gd`)
  - Spawn de efeitos
  - Gerenciamento de pools
  - Efeitos de partículas

- **Abilities** (`src/upgrades/abilities/`)
  - Fire Burn (queimadura)
  - Fire Explosion (explosões)
  - Chain Lightning (raios em cadeia)
  - Thunder Strike (trovões)
  - Overload (sobrecarga)

## 🔄 Fluxo de Dados

### 1. Combate
```
Player atira → Bullet spawna → Bullet acerta Enemy
    ↓
Enemy.take_damage() → DamageComponent processa
    ↓
Abilities.on_projectile_hit() → Efeitos VFX
    ↓
Enemy morre → XP recompensado → EventBus.enemy_died
```

### 2. Progressão
```
Enemy morre → XP ganho → PlayerLevel.add_xp()
    ↓
XP suficiente → Level up → EventBus.player_leveled_up
    ↓
UpgradeUI abre → Player escolhe → UpgradeManager.apply_upgrade()
    ↓
Efeitos aplicados → Habilidades ativadas
```

### 3. VFX
```
Habilidade ativada → on_projectile_hit() chamado
    ↓
VFXManager.spawn_*() → ObjectPool.acquire()
    ↓
Efeito visual spawna → Animação/Partículas
    ↓
Efeito termina → ObjectPool.return()
```

## 📊 Hierarquia de Cenas

### Game.tscn (Cena Principal)
```
Game (Node2D)
├── Player (CharacterBody2D)
│   ├── AnimatedSprite2D
│   ├── CollisionShape2D
│   ├── Camera2D
│   ├── UpgradeManager (Node)
│   └── PlayerLevel (Node)
├── EnemySpawner (Node2D)
├── Camera2D
└── UI (CanvasLayer)
    ├── HUD (CanvasLayer)
    │   ├── Root (Control)
    │   │   ├── TopBar (HBoxContainer)
    │   │   │   ├── WaveLabel
    │   │   │   ├── StateLabel
    │   │   │   ├── EnemiesLabel
    │   │   │   └── HPBox (VBoxContainer)
    │   │   │       ├── HPLabel
    │   │   │       └── HPBar (ProgressBar)
    │   │   ├── XPBar (ProgressBar)
    │   │   └── XPLabel
    └── UpgradeUI (Control)
        ├── Background (ColorRect)
        └── Panel (PanelContainer)
            └── VBox (VBoxContainer)
                ├── Header (VBoxContainer)
                │   ├── Title
                │   └── Subtitle
                ├── Cards (HBoxContainer)
                │   └── [Cards dinâmicos]
                └── Footer (VBoxContainer)
                    └── Hint
```

### Player.tscn
```
Player (CharacterBody2D)
├── AnimatedSprite2D
├── CollisionShape2D
├── Camera2D
├── UpgradeManager (Node)
└── PlayerLevel (Node)
```

### Bullet.tscn
```
Bullet (Area2D)
├── Sprite2D
└── CollisionShape2D
```

### Enemy.tscn (alien.tscn)
```
Alien (CharacterBody2D)
├── AnimatedSprite2D
├── CollisionShape2D
├── StatusEffectComponent (Node)
└── DamageComponent (Node)
```

## 🎨 Sistema de Upgrades

### Árvore de Upgrades - Fire 🔥
```
fire_core (Núcleo de Fogo)
    ├── fire_explosion (Explosão Flamejante)
    │   └── Nível 1-3
    ├── fire_intensity (Intensidade Ardente)
    │   └── Nível 1-3
    └── fire_capstone (Inferno Supremo)
        └── Requer: fire_core + (fire_explosion 3 OU fire_intensity 3)
```

### Árvore de Upgrades - Lightning ⚡
```
lightning_core (Núcleo Elétrico)
    ├── lightning_thunder (Trovão Celestial)
    │   └── Nível 1-3
    ├── lightning_overload (Sobrecarga)
    │   └── Nível 1-3
    └── lightning_capstone (Tempestade Perfeita)
        └── Requer: lightning_core + (lightning_thunder 3 OU lightning_overload 3)
```

## 🔧 Configurações Importantes

### project.godot
```ini
[autoload]
EventBus="*res://src/core/autoload/event_bus.gd"
ObjectPool="*res://src/core/autoload/object_pool.gd"
VFXManager="*res://src/vfx/vfx_manager.gd"

[display]
window/size/viewport_width=1920
window/size/viewport_height=1080

[input]
ui_left={...}
ui_right={...}
ui_up={...}
ui_down={...}

[layer_names]
2d_physics/layer_1="Player"
2d_physics/layer_2="Enemy"
2d_physics/layer_3="PlayerProjectile"
2d_physics/layer_4="EnemyProjectile"
```

## 📝 Convenções de Código

### Nomenclatura
- **Classes**: PascalCase (`PlayerLevel`, `UpgradeManager`)
- **Variáveis**: snake_case (`max_health`, `fire_rate`)
- **Constantes**: UPPER_SNAKE_CASE (`MAX_LEVEL`, `BASE_DAMAGE`)
- **Sinais**: snake_case (`level_up`, `enemy_died`)
- **Funções privadas**: Prefixo `_` (`_apply_effects`, `_on_ready`)

### Estrutura de Arquivo
```gdscript
extends Node
class_name MinhaClasse

# Sinais
signal meu_sinal(param: int)

# Constantes
const MAX_VALUE := 100

# Exports
@export var velocidade := 10.0

# Variáveis públicas
var health := 100.0

# Variáveis privadas
var _internal_state := 0

# Funções built-in
func _ready():
    pass

func _process(delta):
    pass

# Funções públicas
func metodo_publico():
    pass

# Funções privadas
func _metodo_privado():
    pass
```

## 🎯 Próximos Passos

### Curto Prazo
- [ ] Balancear valores de dano e cooldowns
- [ ] Adicionar mais tipos de inimigos
- [ ] Implementar boss (boss_alien.tscn)
- [ ] Adicionar efeitos sonoros
- [ ] Melhorar visual da UI

### Médio Prazo
- [ ] Sistema de power-ups temporários
- [ ] Mais linhas de upgrades (Ice, Poison, etc.)
- [ ] Sistema de conquistas
- [ ] Menu principal
- [ ] Tela de game over

### Longo Prazo
- [ ] Múltiplas arenas
- [ ] Sistema de personagens
- [ ] Modo endless
- [ ] Leaderboards
- [ ] Multiplayer local

---

**Projeto: Starburn Survivors**
**Engine: Godot 4.5**
**Gênero: Vampire Survivors-like**
**Status: Em Desenvolvimento**
