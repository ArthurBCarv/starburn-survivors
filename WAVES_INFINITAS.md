# 🌊 Sistema de Waves Infinitas - Guia Completo

## 📋 Visão Geral

O sistema de waves infinitas foi implementado com **dificuldade crescente progressiva**, garantindo que o jogo se torne cada vez mais desafiador conforme o jogador avança.

---

## 🎯 Características Principais

### 1. **Waves Infinitas**
- ✅ Nunca acabam - continue jogando indefinidamente
- ✅ Cada wave é mais difícil que a anterior
- ✅ Intervalo entre waves diminui progressivamente
- ✅ Boss a cada 5 waves

### 2. **Escalonamento de Dificuldade**

#### Número de Inimigos
```
Wave 1:  5 inimigos
Wave 2:  6 inimigos (5 × 1.2)
Wave 3:  7 inimigos (5 × 1.2²)
Wave 4:  8 inimigos (5 × 1.2³)
Wave 5:  BOSS + 3 minions
Wave 10: BOSS + 4 minions
Wave 20: BOSS + 9 minions
...
```

**Fórmula**: `inimigos = base × crescimento^(wave-1)`
- Base: 5 inimigos
- Crescimento: 1.2x por wave
- Limite máximo: 100 inimigos por wave

#### Intervalo Entre Waves
```
Wave 1:  20.0 segundos
Wave 2:  19.5 segundos
Wave 3:  19.0 segundos
Wave 10: 15.5 segundos
Wave 20: 10.5 segundos
Wave 30: 5.0 segundos (mínimo)
```

**Fórmula**: `intervalo = max(5.0, 20.0 - wave × 0.5)`

#### Velocidade de Spawn
```
Wave 1:  0.1-0.5 segundos entre spawns
Wave 10: 0.05-0.25 segundos entre spawns
Wave 20: 0.025-0.125 segundos entre spawns
```

**Fórmula**: `delay = base_delay / (1.0 + wave × 0.05)`

### 3. **Sistema de Elites**

Inimigos elite têm chance de spawnar e são mais fortes:

```
Wave 1:  10% de chance
Wave 5:  20% de chance
Wave 10: 30% de chance
Wave 20: 50% de chance (máximo)
```

**Fórmula**: `chance = min(0.5, 0.1 + wave × 0.02)`

### 4. **Boss Waves**

A cada 5 waves, uma wave de boss aparece:

```
Wave 5:  1 Boss + 3 minions
Wave 10: 1 Boss + 4 minions
Wave 15: 1 Boss + 6 minions
Wave 20: 1 Boss + 9 minions
```

**Fórmula**: `minions = 3 × 1.5^(boss_count-1)`

---

## ⚙️ Configurações do Spawner

### Configurações Básicas
```gdscript
@export var enabled := true
@export var spawn_margin := 100.0
@export var min_spawn_distance := 150.0
```

### Configurações de Waves
```gdscript
@export var wave_interval := 20.0          # Tempo inicial entre waves
@export var min_wave_interval := 5.0      # Intervalo mínimo
@export var wave_interval_decrease := 0.5 # Quanto diminui por wave
```

### Configurações de Dificuldade
```gdscript
@export var enemies_per_wave_base := 5      # Inimigos iniciais
@export var enemies_per_wave_growth := 1.2  # Multiplicador de crescimento
@export var max_enemies_per_wave := 100     # Limite máximo
@export var boss_wave_interval := 5         # Boss a cada X waves
@export var elite_spawn_chance := 0.1       # Chance inicial de elite
@export var elite_chance_growth := 0.02     # Crescimento da chance
```

### Configurações de Boss Waves
```gdscript
@export var boss_minions_base := 3        # Minions iniciais com boss
@export var boss_minions_growth := 1.5    # Crescimento de minions
```

---

## 📊 Progressão de Dificuldade

### Tabela de Waves

| Wave | Tipo | Inimigos | Intervalo | Elite % | Observação |
|------|------|----------|-----------|---------|------------|
| 1 | Normal | 5 | 20.0s | 10% | Início fácil |
| 2 | Normal | 6 | 19.5s | 12% | - |
| 3 | Normal | 7 | 19.0s | 14% | - |
| 4 | Normal | 8 | 18.5s | 16% | - |
| 5 | **BOSS** | 1+3 | 18.0s | - | Primeiro boss |
| 10 | **BOSS** | 1+4 | 15.5s | - | Boss mais forte |
| 15 | **BOSS** | 1+6 | 13.0s | - | - |
| 20 | **BOSS** | 1+9 | 10.5s | - | Muito difícil |
| 25 | **BOSS** | 1+13 | 8.0s | - | - |
| 30 | **BOSS** | 1+19 | 5.0s | - | Intervalo mínimo |
| 50 | **BOSS** | 1+76 | 5.0s | - | Caos total! |

### Gráfico de Crescimento

```
Inimigos por Wave (Normal):
100 |                                    ████
 90 |                               █████
 80 |                          █████
 70 |                     █████
 60 |                ████
 50 |           ████
 40 |      ████
 30 |  ████
 20 | ██
 10 |█
  5 |█
    +----------------------------------------
    1  5  10  15  20  25  30  35  40  45  50
                    Wave Number
```

---

## 🎮 Como Funciona

### Ciclo de uma Wave

1. **Início da Wave**
   - Calcula número de inimigos
   - Determina se é boss wave
   - Emite sinais de início

2. **Spawn de Inimigos**
   - Spawna inimigos com delay
   - Posiciona fora da câmera
   - Aplica escalonamento de wave

3. **Durante a Wave**
   - Conta inimigos vivos
   - Registra mortes
   - Atualiza estatísticas

4. **Fim da Wave**
   - Todos inimigos mortos
   - Emite sinais de conclusão
   - Inicia timer para próxima wave

5. **Próxima Wave**
   - Aumenta dificuldade
   - Diminui intervalo
   - Repete o ciclo (INFINITO!)

### Spawn de Inimigos

```gdscript
# Posicionamento
1. Calcula área visível da câmera
2. Expande com margem de spawn
3. Escolhe lado aleatório (cima/baixo/esquerda/direita)
4. Garante distância mínima do player

# Tipo de Inimigo
1. Boss (se for boss wave e primeiro spawn)
2. Elite (chance crescente)
3. Normal (padrão)

# Escalonamento
1. Aplica scale_with_wave(current_wave)
2. Inimigos ficam mais fortes a cada wave
```

---

## 🔧 Funções Úteis

### Controle do Spawner

```gdscript
# Pausar spawning
spawner.stop_spawning()

# Retomar spawning
spawner.resume_spawning()

# Obter wave atual
var wave = spawner.get_current_wave()

# Obter inimigos vivos
var alive = spawner.get_enemies_alive()

# Obter total morto
var killed = spawner.get_total_killed()

# Obter multiplicador de dificuldade
var difficulty = spawner.get_difficulty_multiplier()
```

### Sinais Disponíveis

```gdscript
# Sinais do Spawner
spawner.wave_started.connect(func(wave, is_boss):
    print("Wave %d iniciada!" % wave)
)

spawner.wave_completed.connect(func(wave):
    print("Wave %d completada!" % wave)
)

spawner.all_enemies_cleared.connect(func():
    print("Todos inimigos eliminados!")
)

# Sinais do EventBus
EventBus.wave_started.connect(func(wave, is_boss, count):
    print("Wave %d: %d inimigos" % [wave, count])
)

EventBus.wave_cleared.connect(func(wave):
    print("Wave %d limpa!" % wave)
)

EventBus.enemy_spawned.connect(func(enemy):
    print("Inimigo spawnou!")
)

EventBus.boss_spawned.connect(func(boss):
    print("BOSS SPAWNOU!")
)
```

---

## 🎯 Balanceamento

### Ajustando Dificuldade

#### Mais Fácil
```gdscript
enemies_per_wave_base = 3           # Menos inimigos
enemies_per_wave_growth = 1.1       # Crescimento mais lento
wave_interval = 30.0                # Mais tempo entre waves
elite_spawn_chance = 0.05           # Menos elites
```

#### Mais Difícil
```gdscript
enemies_per_wave_base = 10          # Mais inimigos
enemies_per_wave_growth = 1.3       # Crescimento mais rápido
wave_interval = 15.0                # Menos tempo entre waves
elite_spawn_chance = 0.2            # Mais elites
min_wave_interval = 3.0             # Intervalo mínimo menor
```

#### Boss Waves Mais Intensas
```gdscript
boss_wave_interval = 3              # Boss a cada 3 waves
boss_minions_base = 5               # Mais minions
boss_minions_growth = 2.0           # Crescimento mais rápido
```

### Curvas de Dificuldade

#### Linear (Mais Previsível)
```gdscript
enemies_per_wave_growth = 1.0       # Sem crescimento exponencial
# Adicione manualmente: enemies_per_wave_base += 1 por wave
```

#### Exponencial (Mais Desafiador)
```gdscript
enemies_per_wave_growth = 1.5       # Crescimento rápido
```

#### Logarítmica (Começa difícil, estabiliza)
```gdscript
# Use fórmula customizada:
# enemies = base + log(wave) * scale_factor
```

---

## 📈 Estatísticas e Métricas

### Console Output

Durante o jogo, o spawner mostra informações detalhadas:

```
[EnemySpawner] ═══════════════════════════════════════
[EnemySpawner] 🌊 WAVE 15 - Wave Normal
[EnemySpawner] 👾 Inimigos: 23
[EnemySpawner] ⏱️  Próxima wave em: 12.5s
[EnemySpawner] 💀 Total mortos: 187
[EnemySpawner] ═══════════════════════════════════════
```

### Tracking de Progresso

```gdscript
# No seu código
func _on_wave_completed(wave: int):
    var stats = {
        "wave": spawner.get_current_wave(),
        "killed": spawner.get_total_killed(),
        "difficulty": spawner.get_difficulty_multiplier(),
        "time_survived": Time.get_ticks_msec() / 1000.0
    }
    print("Estatísticas: ", stats)
```

---

## 🐛 Debug e Testes

### Comandos de Debug

Adicione no player ou em um script de debug:

```gdscript
func _input(event):
    if event is InputEventKey and event.pressed:
        match event.keycode:
            KEY_F1:  # Pular para próxima wave
                spawner._start_next_wave()
            KEY_F2:  # Matar todos inimigos
                get_tree().call_group("enemies", "queue_free")
            KEY_F3:  # Pausar spawning
                spawner.stop_spawning()
            KEY_F4:  # Retomar spawning
                spawner.resume_spawning()
            KEY_F5:  # Mostrar estatísticas
                print("Wave: %d, Vivos: %d, Mortos: %d" % [
                    spawner.get_current_wave(),
                    spawner.get_enemies_alive(),
                    spawner.get_total_killed()
                ])
```

### Teste de Stress

```gdscript
# Pular para wave específica
spawner.current_wave = 50
spawner._start_next_wave()

# Spawnar muitos inimigos de uma vez
for i in 100:
    spawner._spawn_enemy()
```

---

## 🎓 Dicas de Gameplay

### Para Jogadores

1. **Waves Iniciais (1-5)**
   - Foque em pegar upgrades básicos
   - Aprenda os padrões de movimento
   - Não se preocupe muito com posicionamento

2. **Waves Médias (6-15)**
   - Comece a combinar upgrades
   - Fique atento aos elites
   - Prepare-se para boss waves

3. **Waves Avançadas (16-30)**
   - Builds especializados são essenciais
   - Movimento constante é crucial
   - Priorize sobrevivência sobre dano

4. **Waves Extremas (31+)**
   - Apenas os melhores builds sobrevivem
   - Cada segundo conta
   - Aproveite os 5 segundos entre waves!

### Estratégias

- **Kiting**: Mantenha distância e atire enquanto se move
- **Crowd Control**: Use upgrades de área para lidar com multidões
- **Burst Damage**: Elimine elites e bosses rapidamente
- **Sustain**: Upgrades de vida/regeneração são essenciais em waves altas

---

## 🚀 Próximas Melhorias (Opcional)

### Ideias para Expandir

1. **Eventos Especiais**
   - Wave de apenas elites
   - Wave de velocidade (inimigos rápidos)
   - Wave de tanques (inimigos resistentes)

2. **Modificadores de Wave**
   - Inimigos com escudo
   - Inimigos que explodem ao morrer
   - Inimigos que curam outros

3. **Recompensas por Wave**
   - XP bônus a cada 10 waves
   - Power-ups temporários
   - Escolha de upgrade extra

4. **Desafios**
   - Sobreviva 30 waves
   - Mate 1000 inimigos
   - Derrote 10 bosses

---

## ✅ Checklist de Implementação

- [x] Sistema de waves infinitas
- [x] Escalonamento de dificuldade
- [x] Boss waves a cada 5 waves
- [x] Sistema de elites
- [x] Diminuição de intervalo entre waves
- [x] Spawn fora da câmera
- [x] Escalonamento de inimigos por wave
- [x] Estatísticas e tracking
- [x] Sinais e eventos
- [x] Funções de controle (pause/resume)

---

**Sistema de Waves Infinitas: 100% Funcional! 🌊**

*Sobreviva o máximo que puder!* 💪🔥⚡
