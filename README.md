# 🦸‍♂️ CardHero - Gerenciador & Batalhas de Agentes

Aplicativo Flutter desenvolvido com arquitetura **Offline-First**, consumo de API REST local, persistência em SQLite e regras completas de jogo por turnos.

---

## 🎮 Funcionalidades do Jogo

- **🏢 Inventário Inicial & Recrutamento**:
  - O jogador já inicia sua jornada com **5 agentes** recrutados no seu esquadrão.
  - O esquadrão suporta até um máximo de **15 agentes**.
  - Possibilidade de recrutar novos agentes da base global ou dispensá-los.
- **📜 Contrato Diário**:
  - Permite resgatar 1 agente aleatório por dia (com bloqueio e contagem regressiva de 24h via `SharedPreferences`).
- **⚔️ Missões e Combates**:
  - Sistema de 3 rodadas contra agentes inimigos com atributos específicos sorteados a cada round (`intelligence`, `strength`, `speed`, `durability`, `power`, `combat`).
  - Ganhos de atributos permanentes para os heróis vitoriosos no SQLite.
- **💾 Offline-First**:
  - Todos os dados consultados da API são salvos no SQLite local (`card_hero.db`). O app funciona normalmente mesmo sem conexão.

---

## 🚀 Como Executar

### 1. Iniciar a API Local (`json-server`)
Em um terminal na raiz do projeto:
```bash
npx json-server db.json -p 3000
```

### 2. Executar no Celular Físico via USB
Se for rodar no celular físico conectado via cabo:
```bash
adb reverse tcp:3000 tcp:3000
flutter run -d <ID_DO_SEU_DISPOSITIVO>
```

### 3. Gerar o APK Instalável
Para gerar o arquivo APK:
```bash
flutter build apk --debug
```
O arquivo gerado estará em:
`build/app/outputs/flutter-apk/app-debug.apk`

---

## 🛠️ Tecnologias Utilizadas
- **Flutter 3.x / Dart**
- **Provider** (Injeção de dependências e gerenciamento de estado)
- **Dio** (Cliente HTTP com interceptors)
- **Sqflite** (Banco de dados relacional local)
- **Shared Preferences** (Persistência de chave-valor para contrato diário)
- **AwesomeDialog & PrimerProgressBar** (Feedback visual e interfaces modernas)
- **CachedNetworkImage** (Cache inteligente de imagens)
