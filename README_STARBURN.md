# 🔥 Starburn Survivors

Um jogo no estilo **Vampire Survivors** desenvolvido em **Godot 4.5**, com sistema completo de upgrades VFX, combate automático e progressão por ondas.

![Godot](https://img.shields.io/badge/Godot-4.5-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![Status](https://img.shields.io/badge/status-em%20desenvolvimento-yellow)

## 🎮 Sobre o Jogo

Starburn Survivors é um jogo de ação roguelike onde você controla um personagem que atira automaticamente em hordas de inimigos. Conforme você ganha experiência e sobe de nível, pode escolher entre diversos upgrades poderosos que modificam suas habilidades com efeitos visuais espetaculares.

### Características Principais

- 🎯 **Combate Automático**: Mire e atire automaticamente no inimigo mais próximo
- ⚡ **Sistema de Upgrades VFX**: Escolha entre upgrades de Fogo e Raio com efeitos visuais únicos
- 🌊 **Sistema de Ondas**: Enfrente ondas crescentes de inimigos
- 👾 **Boss Battles**: Enfrente chefes poderosos a cada 5 ondas
- 📊 **Progressão por XP**: Ganhe experiência, suba de nível e fique mais forte
- 🎨 **Efeitos Visuais**: Explosões, raios, queimaduras e muito mais

## 🚀 Como Jogar

### Instalação

1. Clone o repositório:
```bash
git clone https://github.com/seu-usuario/starburn-survivors.git
cd starburn-survivors
```

2. Abra o projeto no Godot 4.5 ou superior

3. Pressione F5 para jogar!

### Controles

- **WASD / Setas**: Mover o personagem
- **Tiro**: Automático (atira no inimigo mais próximo)
- **T**: Ganhar XP rapidamente (modo debug)
- **ESC**: Fechar UI de upgrade

## 🔥⚡ Sistema de Upgrades

### Linha de Fogo 🔥

| Upgrade | Descrição | Efeito |
|---------|-----------|--------|
| **Núcleo de Fogo** | Seus tiros aplicam queimadura | Dano ao longo do tempo |
| **Explosão Flamejante** | Cria explosões ao acertar | Dano em área |
| **Intensidade Ardente** | Aumenta o poder do fogo | +Dano, +Queimadura |
| **Inferno Supremo** | Explosões aplicam queimadura | Combo devastador |

### Linha de Raio ⚡

| Upgrade | Descrição | Efeito |
|---------|-----------|--------|
| **Núcleo Elétrico** | Raios saltam entre inimigos | Dano em cadeia |
| **Trovão Celestial** | Invoca raios do céu | Dano + Atordoamento |
| **Sobrecarga** | Dano extra em atordoados | +Dano, +Cadência |
| **Tempestade Perfeita** | Raios mais poderosos | Combo elétrico |

## 📁 Estrutura do Projeto

```
starburn-survivors/
├── src/
│   ├── core/           # Sistemas centrais (EventBus, ObjectPool, VFXManager)
│   ├── player/         # Jogador e sistemas de progressão
│   ├── enemy/          # Inimigos e spawner
│   ├── weapons/        # Armas e projéteis
│   ├── upgrades/       # Sistema de upgrades e habilidades
│   ├── vfx/            # Efeitos visuais
│   └── ui/             # Interface do usuário
├── levels/             # Cenas de níveis
├── assets/             # Assets (sprites, sons, etc.)
└── addons/             # Plugins do Godot
```

Para mais detalhes, veja [ESTRUTURA_PROJETO.md](ESTRUTURA_PROJETO.md)

## 🛠️ Desenvolvimento

### Tecnologias

- **Engine**: Godot 4.5
- **Linguagem**: GDScript
- **Padrões**: Observer, Object Pool, Builder

### Arquitetura

O projeto utiliza uma arquitetura modular com:

- **Autoloads**: EventBus, ObjectPool, VFXManager
- **Componentes**: DamageComponent, StatusEffectComponent
- **Sistemas**: UpgradeManager, PlayerLevel, EnemySpawner

### Documentação

- 📖 [Guia de Teste Rápido](GUIA_TESTE_RAPIDO.md)
- 📋 [Checklist de Testes](CHECKLIST_TESTE.md)
- 🔧 [Correções Aplicadas](CORREÇÕES_VFX.md)
- 💡 [Dicas de Desenvolvimento](DICAS_DESENVOLVIMENTO.md)
- 📊 [Estrutura do Projeto](ESTRUTURA_PROJETO.md)

## 🧪 Testando

### Teste Rápido (1 minuto)

1. Abra o projeto no Godot
2. Pressione F5
3. Pressione T várias vezes para ganhar XP
4. Escolha um upgrade quando a UI abrir
5. Veja os efeitos VFX em ação!

### Teste Completo

Siga o [Checklist de Testes](CHECKLIST_TESTE.md) para testar todos os recursos.

## 🎯 Roadmap

### ✅ Implementado

- [x] Sistema de combate automático
- [x] Sistema de progressão (XP/Level)
- [x] UI de upgrades
- [x] Upgrades de Fogo (4 upgrades)
- [x] Upgrades de Raio (4 upgrades)
- [x] Sistema de VFX completo
- [x] Sistema de ondas
- [x] Spawn de inimigos

### 🚧 Em Desenvolvimento

- [ ] Balanceamento de valores
- [ ] Boss battles
- [ ] Mais tipos de inimigos
- [ ] Efeitos sonoros
- [ ] Melhorias visuais na UI

### 📅 Planejado

- [ ] Novas linhas de upgrades (Gelo, Veneno)
- [ ] Sistema de power-ups temporários
- [ ] Múltiplas arenas
- [ ] Sistema de personagens
- [ ] Menu principal
- [ ] Tela de game over
- [ ] Sistema de conquistas

## 🤝 Contribuindo

Contribuições são bem-vindas! Veja [CONTRIBUTING.md](CONTRIBUTING.md) para mais detalhes.

### Como Contribuir

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/MinhaFeature`)
3. Commit suas mudanças (`git commit -m 'Adiciona MinhaFeature'`)
4. Push para a branch (`git push origin feature/MinhaFeature`)
5. Abra um Pull Request

## 📝 Licença

Este projeto está sob a licença MIT. Veja [LICENSE](LICENSE) para mais detalhes.

## 🙏 Agradecimentos

- **Godot Engine** - Engine incrível e open source
- **Vampire Survivors** - Inspiração para o gameplay
- Comunidade Godot - Tutoriais e suporte

## 📧 Contato

- **Projeto**: [GitHub](https://github.com/seu-usuario/starburn-survivors)
- **Issues**: [Bug Reports](https://github.com/seu-usuario/starburn-survivors/issues)

---

**Desenvolvido com ❤️ usando Godot 4.5**

*Sobreviva às ondas, escolha seus upgrades, domine o poder do fogo e do raio!* 🔥⚡
