# 🎮 Teste Rápido - Waves Infinitas

## ⚡ Teste em 2 Minutos

### 1. Abrir o Projeto
```bash
# Abra o Godot e carregue o projeto
# Ou via terminal:
cd L:/Documentos/GitHub/starburn-survivors
godot project.godot
```

### 2. Rodar o Jogo
- Pressione **F5** ou clique em "Play"
- A cena `Game.tscn` deve iniciar automaticamente

### 3. O Que Observar

#### ✅ Console Output
Você deve ver mensagens como:
```
[EnemySpawner] Sistema de waves infinitas iniciado!
[EnemySpawner] Configuração: 5 inimigos base, crescimento 1.2x
[EnemySpawner] ═══════════════════════════════════════
[EnemySpawner] 🌊 WAVE 1 - Wave Normal
[EnemySpawner] 👾 Inimigos: 5
[EnemySpawner] ⏱️  Próxima wave em: 20.0s
[EnemySpawner] 💀 Total mortos: 0
[EnemySpawner] ═══════════════════════════════════════
```

#### ✅ Gameplay
- **Wave 1-4**: Inimigos spawnam gradualmente (5-8 inimigos)
- **Wave 5**: BOSS aparece com 3 minions
- **Wave 6+**: Mais inimigos, intervalo menor
- **Wave 10**: BOSS com 4 minions

#### ✅ HUD
- Contador de wave deve atualizar
- Número de inimigos vivos deve aparecer
- XP e level devem funcionar

---

## 🎯 Teste Completo (5 Minutos)

### Fase 1: Waves Iniciais (1-5)
**Objetivo**: Verificar spawn básico

- [ ] Wave 1 começa automaticamente
- [ ] 5 inimigos spawnam
- [ ] Inimigos aparecem fora da tela
- [ ] Ao matar todos, wave 2 começa em 20s
- [ ] Wave 5 spawna um BOSS

**Console esperado**:
```
[EnemySpawner] 🌊 WAVE 1 - Wave Normal
[EnemySpawner] 👾 Inimigos: 5
[EnemySpawner] ✅ Wave 1 completada!
[EnemySpawner] ⏳ Próxima wave em 20.0 segundos...
```

### Fase 2: Progressão (6-10)
**Objetivo**: Verificar crescimento de dificuldade

- [ ] Número de inimigos aumenta
- [ ] Intervalo entre waves diminui
- [ ] Wave 10 spawna BOSS com mais minions

**Console esperado**:
```
[EnemySpawner] 🌊 WAVE 10 - BOSS WAVE
[EnemySpawner] 👾 Inimigos: 5 (1 boss + 4 minions)
[EnemySpawner] 👑 BOSS SPAWNOU!
```

### Fase 3: Waves Avançadas (15+)
**Objetivo**: Verificar limite e performance

- [ ] Muitos inimigos na tela
- [ ] Jogo continua rodando suavemente
- [ ] Boss waves ficam mais difíceis
- [ ] Intervalo chega ao mínimo (5s)

---

## 🐛 Comandos de Debug

### Adicionar ao Player (Opcional)

Abra `src/player/player.gd` e adicione:

```gdscript
func _input(event):
    if event is InputEventKey and event.pressed:
        match event.keycode:
            KEY_F1:  # Pular para próxima wave
                var spawner = get_node("/root/Game/EnemySpawner")
                if spawner:
                    spawner._start_next_wave()
                    print("[DEBUG] Pulando para próxima wave")
            
            KEY_F2:  # Matar todos inimigos
                get_tree().call_group("enemies", "queue_free")
                print("[DEBUG] Todos inimigos mortos")
            
            KEY_F3:  # Pausar spawning
                var spawner = get_node("/root/Game/EnemySpawner")
                if spawner:
                    spawner.stop_spawning()
                    print("[DEBUG] Spawning pausado")
            
            KEY_F4:  # Retomar spawning
                var spawner = get_node("/root/Game/EnemySpawner")
                if spawner:
                    spawner.resume_spawning()
                    print("[DEBUG] Spawning retomado")
            
            KEY_F5:  # Mostrar estatísticas
                var spawner = get_node("/root/Game/EnemySpawner")
                if spawner:
                    print("[DEBUG] ═══════════════════════════════")
                    print("[DEBUG] Wave Atual: %d" % spawner.get_current_wave())
                    print("[DEBUG] Inimigos Vivos: %d" % spawner.get_enemies_alive())
                    print("[DEBUG] Total Mortos: %d" % spawner.get_total_killed())
                    print("[DEBUG] Dificuldade: %.2fx" % spawner.get_difficulty_multiplier())
                    print("[DEBUG] ═══════════════════════════════")
```

### Teclas de Debug
- **F1**: Pular para próxima wave
- **F2**: Matar todos inimigos
- **F3**: Pausar spawning
- **F4**: Retomar spawning
- **F5**: Mostrar estatísticas

---

## ✅ Checklist Rápido

### Funcionalidades Básicas
- [ ] Waves começam automaticamente
- [ ] Inimigos spawnam fora da câmera
- [ ] Número de inimigos aumenta
- [ ] Boss aparece na wave 5
- [ ] Intervalo entre waves diminui

### Progressão
- [ ] Wave 1: 5 inimigos
- [ ] Wave 5: 1 boss + 3 minions
- [ ] Wave 10: 1 boss + 4 minions
- [ ] Wave 20: ~25 inimigos ou boss

### Performance
- [ ] Sem lag até wave 10
- [ ] Spawn não causa stuttering
- [ ] Console mostra informações corretas

### UI/HUD
- [ ] Contador de wave atualiza
- [ ] Número de inimigos correto
- [ ] XP e level funcionam

---

## 🔍 O Que Procurar

### ✅ Sinais de Sucesso

1. **Console Limpo**
   ```
   [EnemySpawner] 🌊 WAVE X - ...
   [EnemySpawner] ✅ Wave X completada!
   ```

2. **Spawn Visível**
   - Inimigos aparecem nas bordas da tela
   - Não spawnam em cima do player

3. **Progressão Clara**
   - Cada wave tem mais inimigos
   - Boss waves são notáveis

4. **Performance Estável**
   - FPS constante
   - Sem travamentos

### ❌ Sinais de Problema

1. **Erros no Console**
   ```
   ERROR: ...
   WARNING: ...
   ```

2. **Spawn Incorreto**
   - Inimigos spawnam em cima do player
   - Nenhum inimigo spawna

3. **Waves Não Progridem**
   - Fica preso na wave 1
   - Não spawna boss na wave 5

4. **Performance Ruim**
   - FPS cai drasticamente
   - Jogo trava

---

## 🎯 Teste de Stress (Opcional)

### Pular para Wave Alta

No console do Godot (durante o jogo):

```gdscript
# Pular para wave 20
var spawner = get_node("/root/Game/EnemySpawner")
spawner.current_wave = 19
spawner._start_next_wave()
```

### Spawnar Muitos Inimigos

```gdscript
# Spawnar 50 inimigos de uma vez
var spawner = get_node("/root/Game/EnemySpawner")
for i in 50:
    spawner._spawn_enemy()
```

---

## 📊 Resultados Esperados

### Wave 1
```
Inimigos: 5
Intervalo: 20.0s
Elite: ~10% chance
```

### Wave 5 (Boss)
```
Inimigos: 1 boss + 3 minions
Intervalo: 18.0s
Boss: Sim
```

### Wave 10 (Boss)
```
Inimigos: 1 boss + 4 minions
Intervalo: 15.5s
Boss: Sim
```

### Wave 20 (Boss)
```
Inimigos: 1 boss + 9 minions
Intervalo: 10.5s
Boss: Sim
```

### Wave 30 (Boss)
```
Inimigos: 1 boss + 19 minions
Intervalo: 5.0s (mínimo)
Boss: Sim
```

---

## 🚨 Troubleshooting

### Problema: Nenhum inimigo spawna
**Solução**:
1. Verifique se `enemy_scenes` está configurado no spawner
2. Abra `Game.tscn` → `EnemySpawner` → `Enemy Scenes`
3. Adicione `alien.tscn` se estiver vazio

### Problema: Boss não spawna
**Solução**:
1. Verifique se `boss_scenes` está configurado
2. Adicione `boss_alien.tscn` ao array

### Problema: Waves não progridem
**Solução**:
1. Verifique se inimigos estão morrendo corretamente
2. Confirme que `EventBus.enemy_died` está sendo emitido
3. Verifique console para erros

### Problema: Performance ruim
**Solução**:
1. Reduza `max_enemies_per_wave` para 50
2. Aumente `enemies_per_wave_growth` para 1.1
3. Verifique se há memory leaks (inimigos não sendo liberados)

---

## 📝 Notas Finais

### O Que Foi Testado
- [x] Sistema de waves infinitas
- [x] Escalonamento de dificuldade
- [x] Boss waves
- [x] Spawn fora da câmera
- [x] Estatísticas e tracking

### Próximos Testes
- [ ] Sistema de elites (se configurado)
- [ ] Performance em waves muito altas (50+)
- [ ] Balanceamento de dificuldade
- [ ] Integração com upgrades

---

**Teste Rápido Completo! 🎮**

*Se tudo funcionar, você está pronto para jogar!* 🌊🔥⚡
