# Sistema de Roguelike - Instruções de Teste

## Visão Geral
Este projeto implementa os sistemas principais de um jogo roguelike em Godot 4:
- Sistema de VFX (efeitos visuais)
- Sistema de dano com componentes
- Sistema de spawn de inimigos com waves
- Sistema de boss
- Sistema de upgrades
- UI integrada

## Como Testar

### 1. Teste Rápido de Sistemas
Execute a cena `src/core/test_systems.tscn` para verificar se todos os autoloads estão funcionando:
- VFXManager
- EventBus
- ObjectPool

### 2. Teste do Jogo Completo
Execute a cena `src/core/game_scene.tscn` para testar o jogo completo:

#### Controles:
- **WASD/Setas**: Movimentação
- **Mouse**: Mira
- **Clique Esquerdo**: Atirar
- **ESC**: Pausar (quando implementado)

#### O que testar:
1. **Movimento do Player**: Verifique se o player se move corretamente
2. **Sistema de Tiro**: Clique para atirar, observe os efeitos visuais
3. **Spawn de Inimigos**: Inimigos devem aparecer em waves
4. **Sistema de Dano**: Atire nos inimigos para destruí-los
5. **Sistema de XP**: Ganhe XP ao matar inimigos
6. **Sistema de Level**: Suba de nível e escolha upgrades
7. **Sistema de Boss**: A cada 5 waves, um boss aparece

### 3. Verificação de Funcionalidades

#### ✅ Sistemas Implementados:
- [x] VFXManager para efeitos visuais
- [x] Sistema de componentes de dano
- [x] Sistema de spawn de inimigos
- [x] Sistema de waves
- [x] Sistema de boss
- [x] Sistema de upgrades
- [x] UI de upgrades
- [x] HUD com barras de vida/XP
- [x] Sistema de level do player
- [x] Object pooling para projéteis

#### 🔧 Correções Aplicadas:
- VFXManager corrigido para funcionar como singleton
- Sinais do EventBus padronizados
- Sistema de upgrades integrado com UI
- Player level conectado ao sistema de XP
- Cenas de partículas criadas

### 4. Estrutura de Arquivos

```
src/
├── core/
│   ├── game_scene.gd       # Script principal do jogo
│   ├── game_scene.tscn     # Cena principal
│   └── test_systems.gd/tscn # Teste de sistemas
├── player/
│   ├── player.gd           # Script do player
│   ├── player_level.gd     # Sistema de level
│   └── upgrade_manager.gd  # Gerenciador de upgrades
├── enemy/
│   ├── enemyBase.gd        # Base para inimigos
│   └── spawner/
│       └── enemy_spawner.gd # Sistema de spawn
├── vfx/
│   ├── vfx_manager.gd      # Gerenciador de efeitos
│   └── particles/          # Cenas de partículas
└── ui/
    └── upgrade_ui/         # UI de seleção de upgrades
```

### 5. Possíveis Problemas e Soluções

#### Erro: "VFXManager not found"
- Verifique se VFXManager está em Project Settings > Autoload
- Path correto: `res://src/vfx/vfx_manager.gd`

#### Erro: "Enemy scenes not configured"
- As cenas de inimigos são carregadas automaticamente no game_scene.gd
- Verifique se as cenas alien.tscn e boss_alien.tscn existem

#### Upgrades não aparecem
- Verifique se o UpgradeManager está no player
- Confirme que o caminho no UpgradeUI está correto

### 6. Próximos Passos
1. Adicionar mais tipos de inimigos
2. Implementar mais upgrades
3. Adicionar sistema de som
4. Implementar menu principal
5. Adicionar sistema de save/load