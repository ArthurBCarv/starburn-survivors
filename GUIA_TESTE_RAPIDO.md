# 🎮 Guia Rápido de Teste - Upgrades VFX

## Como Testar Agora

### 1. Abra o Projeto no Godot
```
Abra o Godot e carregue o projeto
```

### 2. Execute a Cena Principal
```
Pressione F5 ou clique em "Play" (▶️)
A cena Game.tscn será carregada automaticamente
```

### 3. Ganhe XP Rapidamente (Modo DEBUG)
```
Pressione a tecla T repetidamente
Cada pressão dá +10 XP
Você precisa de 20 XP para o primeiro level up
```

### 4. Escolha um Upgrade
```
Quando subir de nível, a UI de upgrade abrirá automaticamente
O jogo pausará
Escolha um dos 3 upgrades disponíveis
```

### 5. Teste os Efeitos VFX

#### 🔥 Para testar Fire (Fogo):
1. Escolha "Núcleo de Fogo" (fire_core)
2. Atire nos inimigos (automático)
3. Observe:
   - Inimigos pegam fogo (queimadura)
   - Dano ao longo do tempo
   - Efeito visual de fogo

#### ⚡ Para testar Lightning (Raio):
1. Escolha "Núcleo Elétrico" (lightning_core)
2. Atire nos inimigos (automático)
3. Observe:
   - Raios saltam entre inimigos
   - Efeito visual de raio
   - Cadência de tiro aumentada

### 6. Teste Upgrades Avançados

#### 💥 Explosão de Fogo:
1. Tenha fire_core
2. Suba de nível novamente (pressione T)
3. Escolha "Explosão Flamejante"
4. Observe explosões ao acertar inimigos

#### 🌩️ Trovão:
1. Tenha lightning_core
2. Suba de nível novamente (pressione T)
3. Escolha "Trovão Celestial"
4. Observe raios caindo do céu aleatoriamente

## Controles

- **WASD / Setas**: Mover o jogador
- **Tiro**: Automático (atira no inimigo mais próximo)
- **T**: Ganhar +10 XP (DEBUG)
- **ESC**: Fechar UI de upgrade (se necessário)

## O que Observar

### ✅ Funcionando Corretamente:
- [ ] UI de upgrade abre ao subir de nível
- [ ] Jogo pausa quando UI abre
- [ ] 3 opções de upgrade aparecem
- [ ] Ao escolher upgrade, UI fecha e jogo despausa
- [ ] Efeitos VFX aparecem ao atirar
- [ ] Inimigos spawnam automaticamente
- [ ] XP é ganho ao matar inimigos
- [ ] Barra de XP atualiza no HUD

### 🔥 Efeitos de Fogo:
- [ ] Queimadura aplica dano ao longo do tempo
- [ ] Explosões causam dano em área
- [ ] Partículas de fogo aparecem
- [ ] Cor laranja/vermelha nos efeitos

### ⚡ Efeitos de Raio:
- [ ] Raios saltam entre inimigos
- [ ] Trovões caem do céu
- [ ] Inimigos ficam atordoados
- [ ] Cor azul elétrica nos efeitos

## Troubleshooting

### UI de upgrade não abre?
1. Verifique o console (Output) para mensagens de erro
2. Confirme que EventBus está carregado (deve aparecer no console)
3. Verifique se o caminho do UpgradeManager está correto

### Sem inimigos?
1. Verifique se EnemySpawner está na cena
2. Aguarde alguns segundos (primeira wave demora um pouco)
3. Verifique o console para mensagens do spawner

### Efeitos VFX não aparecem?
1. Verifique se VFXManager está carregado (autoload)
2. Confirme que as cenas VFX existem em src/vfx/
3. Verifique o console para erros de carregamento

### Jogo não despausa após escolher upgrade?
1. Pressione ESC para fechar a UI manualmente
2. Verifique se há múltiplas UIs abertas (bug de duplicação)

## Dicas

💡 **Combine upgrades**: Fire + Lightning cria um build híbrido poderoso!

💡 **Teste os capstones**: São os upgrades mais poderosos, mas requerem outros upgrades primeiro

💡 **Observe os números**: Dano e efeitos aumentam a cada nível

💡 **Boss waves**: A cada 5 waves aparece um boss (mais forte, mais XP)

## Próximos Testes

Após confirmar que tudo funciona:
1. Teste diferentes combinações de upgrades
2. Chegue até wave 5 para ver o boss
3. Tente pegar todos os upgrades de uma linha (Fire ou Lightning)
4. Teste o capstone (upgrade final de cada linha)

---

**Divirta-se testando! 🎮🔥⚡**
