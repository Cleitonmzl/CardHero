# Documentação Técnica e Arquitetura do CardHero

Este documento detalha o funcionamento de todo o código-fonte do aplicativo **CardHero**, explicando a arquitetura adotada, o funcionamento das telas, o uso específico de widgets de layout (**Row**, **Column**, **Stack**, **Slivers**, **GridView**, etc.), a implementação da paginação infinita e a estratégia **Offline-First**.

---

## 1. Visão Geral da Arquitetura

O projeto adota os princípios de Clean Architecture e separação de responsabilidades em camadas:

```
lib/
├── core/
│   └── di/
│       └── configure_providers.dart    # Injeção de dependência via Provider
├── domain/
│   └── hero_model.dart                 # Modelo de domínio unificado (HeroModel)
├── data/
│   ├── database/
│   │   ├── app_database.dart           # Inicialização e schemas do SQLite
│   │   └── dao/
│   │       └── hero_dao.dart           # Data Access Object com queries SQL
│   ├── network/
│   │   └── client/
│   │       └── api_client.dart         # Comunicação HTTP REST com a API
│   └── repository/
│       └── hero_repository.dart        # Repositório com estratégia Offline-First
├── ui/
│   ├── page/
│   │   ├── home_page.dart              # Menu principal (Hub Central)
│   │   ├── agents_list_page.dart       # Catálogo geral com paginação infinita
│   │   ├── agent_details_page.dart     # Detalhes completos do agente
│   │   ├── my_squad_page.dart          # Gestão do esquadrão do jogador (até 15)
│   │   ├── my_agent_details_page.dart  # Detalhes e dispensa do esquadrão
│   │   ├── daily_contract_page.dart    # Recrutamento diário por sorteio
│   │   └── missions_page.dart          # Central tática de combate por rodadas
│   └── widgets/
│       └── hero_card.dart              # Card reutilizável de apresentação de agente
└── main.dart                           # Ponto de entrada e configuração do tema
```

---

## 2. Injeção de Dependência (`configure_providers.dart` & `main.dart`)

- **Biblioteca utilizada:** `provider`.
- **Fluxo de Inicialização:**
  1. `main()` chama `WidgetsFlutterBinding.ensureInitialized()`.
  2. Executa `ConfigureProviders.createDependencyTree()`.
  3. Instancia `ApiClient`, `AppDatabase` e `HeroDao`.
  4. Instancia `HeroRepository` e executa:
     - `heroRepository.seedHeroesFromAssets()`: garante o pré-carregamento dos 730+ agentes no SQLite.
     - `heroRepository.ensureInitialSquad()`: garante que a conta do jogador inicie imediatamente com **5 agentes** no esquadrão.
  5. Envolve o `MaterialApp` com `MultiProvider`, disponibilizando repositórios e DAOs em toda a árvore de widgets via `Provider.of<T>(context)`.

---

## 3. Estratégia Offline-First e Banco Local SQLite

### 3.1. Tabelas SQLite (`app_database.dart`)
1. `heroes_cache`: Cache de todos os super-heróis conhecidos da API. Guarda atributos de combate (`intelligence`, `strength`, `speed`, `durability`, `power`, `combat`), aparências, biografia e URLs das imagens.
2. `squad`: Tabela dos agentes recrutados no esquadrão do jogador (limite máximo de 15 agentes).

### 3.2. Seed Offline a partir de Assets
- **Arquivo embarcado:** `assets/data/db.json` (declarado no `pubspec.yaml`).
- **Como funciona:**
  - O método `seedHeroesFromAssets()` em `HeroRepository` verifica `heroDao.getCachedHeroesCount()`.
  - Se houver menos de 50 registros no banco local, lê `rootBundle.loadString('assets/data/db.json')`, decodifica o JSON e insere em lote via `heroDao.insertHeroes()`.
  - Isso garante que o app funcione 100% de forma autônoma em qualquer celular físico sem depender de Wi-Fi ou servidores locais.

### 3.3. Sorteio Nativo de Oponentes (`hero_dao.dart`)
- **Problema resolvido:** Missões e Contratos Diários precisam de agentes que **não** estejam no esquadrão.
- **Implementação SQL:**
  ```sql
  SELECT * FROM heroes_cache 
  WHERE id NOT IN (?, ?, ?, ?, ?) 
  ORDER BY RANDOM() 
  LIMIT 1
  ```
  Essa query SQL nativa elimina loops imperfeitos e garante seleção instantânea entre as centenas de heróis disponíveis.

---

## 4. Paginação Infinita (`agents_list_page.dart`)

- **Biblioteca utilizada:** `infinite_scroll_pagination` (versão 4.x / 5.x).
- **Como funciona:**
  1. É instanciado um `PagingController<int, HeroModel>` no estado da página:
     ```dart
     late final PagingController<int, HeroModel> _pagingController = PagingController<int, HeroModel>(
       getNextPageKey: (state) => state.lastPageIsEmpty ? null : state.nextIntPageKey,
       fetchPage: (pageKey) => _heroRepository.getHeroes(page: pageKey, limit: 10),
     );
     ```
  2. `getNextPageKey`: Analisa o estado atual. Se a última página retornada vier vazia, retorna `null`, sinalizando o fim da lista. Caso contrário, solicita `state.nextIntPageKey` (página 1, 2, 3...).
  3. `fetchPage`: Invoca `_heroRepository.getHeroes(page: pageKey, limit: 10)`. O repositório tenta a API remota; em caso de falha de conexão, busca do cache SQLite com `offset = (page - 1) * limit`.
  4. **Estrutura de Widgets na Tela:**
     - `Scaffold`: Estrutura base da tela com fundo Slate escuro (`#0F172A`).
     - `AppBar`: Título e botão de ação com `IconButton` para acionar `_pagingController.refresh()`.
     - `PagingListener`: Escuta as mudanças de estado do controlador e fornece a função `fetchNextPage`.
     - `PagedListView<int, HeroModel>`: Lista reativa com `PagedChildBuilderDelegate` que renderiza o `HeroCard` para cada item, além de indicadores de carregamento (`CircularProgressIndicator`) para a primeira página e para as páginas subsequentes.

---

## 5. Detalhamento das Telas, Widgets e Estrutura de Layout

### 5.1. Tela Inicial (`home_page.dart`)
- **Propósito:** Hub central de comando com design moderno no tema militar tático.
- **Widgets de Layout Utilizados:**
  - `Scaffold` com `AppBar`: Título centralizado com `Row` abrigando ícone de escudo e texto em negrito espaçado.
  - `SafeArea` + `Padding`: Garante distanciamento seguro das bordas do dispositivo.
  - `Column`: Empilha o Banner Superior e o Grid de Ações.
  - `Container` (Banner): Usa `BoxDecoration` com `LinearGradient` (tons de azul) e `BoxShadow` com elevação e bordas arredondadas.
  - `Expanded` + `GridView.count`:
    - `crossAxisCount: 2`: Divide o menu em duas colunas idênticas.
    - `crossAxisSpacing` e `mainAxisSpacing`: Espaçamento simétrico de 16px.
    - Renderiza 4 cartões com `_MenuCard` (Agentes, Contrato Diário, Meu Esquadrão, Missões).
  - `_MenuCard`:
    - `Material` + `InkWell`: Fornece efeito visual de clique (ripple effect/splash color).
    - `Column`: Centraliza verticalmente o ícone circular (`Container` com fundo translúcido e `BoxShape.circle`), o título principal em negrito e o subtítulo explicativo.

---

### 5.2. Card Reutilizável de Agente (`hero_card.dart`)
- **Propósito:** Componente padronizado para exibir qualquer herói em listas (catálogo e esquadrão).
- **Widgets de Layout Utilizados:**
  - `Card`: Cantos arredondados (`BorderRadius.circular(16)`), borda cinza sutil e elevação.
  - `InkWell`: Detecta toques e dispara o callback `onTap`.
  - `Row`: Estrutura horizontal dividida em 3 partes:
    1. **Miniatura à esquerda:**
       - `ClipRRect`: Arredonda os cantos da imagem.
       - `CachedNetworkImage`: Cache de imagem em disco/memória com dimensões fixas (72x72), com fallback para ícone genérico em caso de erro ou sem rede.
    2. **Dados textuais ao centro (`Expanded` + `Column`):**
       - Nome do agente (`Text` com `TextOverflow.ellipsis`).
       - Subtítulo dinâmico (Raça/Gênero ou maior powerstat).
       - `Row` com Badges de Powerstats (`_StatBadge`): Badges para Força (STR), Inteligência (INT) e Combate (CMB).
    3. **Indicador à direita:**
       - `Icon(Icons.arrow_forward_ios_rounded)` para indicar navegabilidade.
  - `_StatBadge`:
    - `Container` com cor de destaque translúcida + borda colorida.
    - `Row` interna contendo ícone e texto do valor numérico.

---

### 5.3. Detalhes do Agente (`agent_details_page.dart`)
- **Propósito:** Exibe ficha técnica completa do agente com imagens em alta resolução e barras de status.
- **Widgets de Layout Utilizados:**
  - `FutureBuilder`: Realiza a busca no repositório com `initialData` do modelo atual, permitindo carregamento instantâneo.
  - `CustomScrollView` + `Slivers`:
    - `SliverAppBar`: Barra com expansão de 380px e recolhimento fixo (`pinned: true`).
    - `FlexibleSpaceBar`: Contém título e fundo dinâmico.
    - **`Stack` (Uso de Sobreposição):**
      - Camada 1: `CachedNetworkImage` ocupando todo o espaço com `BoxFit.cover`.
      - Camada 2: `DecoratedBox` com `LinearGradient` escuro sobreposto, escurecendo a base para que o texto do título fique perfeitamente legível e a transição para o conteúdo seja suave.
    - `SliverToBoxAdapter`: Converte widgets convencionais de caixa (`Column`, `Padding`) para o ecossistema de Slivers.
  - `primer_progress_bar`:
    - Utilizado em `_buildStatsCard` para exibir barras gráficas de progresso segmentadas para cada um dos 6 atributos (Inteligência, Força, Velocidade, Durabilidade, Poder, Combate).
  - Cards de Informação (`_buildInfoCard`):
    - `Column` com múltiplas `Row`s para pares rótulo-valor (Gênero, Raça, Altura, Peso, Alinhamento, Editora).

---

### 5.4. Meu Esquadrão (`my_squad_page.dart`)
- **Propósito:** Gerenciar a equipe ativa do jogador (mínimo 5 agentes iniciais, máximo 15).
- **Widgets de Layout Utilizados:**
  - `AppBar`: Inclui um contador estilizado no canto superior direito (`Row` / `Container` com borda verde) exibindo `X / 15`.
  - `ListView.builder`: Renderiza a lista de agentes usando o `HeroCard`.
  - Passagem de `subtitleOverride` para destacar o maior atributo do herói (ex: `"Maior Atributo: combat: 95"`).
  - Atualização reativa: Ao retornar da tela de detalhes (`Navigator.push`), verifica se o retorno foi `true` (agente dispensado) e reexecuta `_loadSquad()`.

---

### 5.5. Detalhes do Membro do Esquadrão e Dispensa (`my_agent_details_page.dart`)
- **Propósito:** Detalhes de agente recrutado com ação de dispensa.
- **Widgets e Bibliotecas:**
  - `CustomScrollView`, `SliverAppBar` e `Stack` com gradiente escuro idênticos ao catálogo.
  - `ElevatedButton.icon`: Botão vermelho de perigo com ícone de saída para dispensar o agente.
  - `AwesomeDialog`:
    - Dispara diálogo animado (`DialogType.warning`, `AnimType.bottomSlide`).
    - Exige confirmação explícita do usuário antes de remover do SQLite (`repo.dismissHero(hero.id)`).
    - Exibe `SnackBar` de confirmação e retorna `Navigator.pop(context, true)`.

---

### 5.6. Contrato Diário (`daily_contract_page.dart`)
- **Propósito:** Recrutamento de novos agentes através de sorteio diário garantido (1 por dia).
- **Mecanismos e Layout:**
  - **Persistência de Data:** Usa `SharedPreferences` para salvar `last_contract_date` (formato ISO `YYYY-MM-DD`) e `last_contract_hero_id`.
  - Se o jogador abrir o app no mesmo dia, recupera o mesmo agente já sorteado.
  - Se for um novo dia, invoca `repo.getRandomHero()` e salva os novos dados.
  - **Apresentação Visual:**
    - `Card` com borda dourada (`Colors.amber`).
    - `Stack` na imagem do contrato para posicionar a tag de recrutamento.
    - Exibe todos os powerstats com `PrimerProgressBar`.
    - Botão de Ação: Alterna dinamicamente entre **"Agente já Recrutado"** (desabilitado em cinza/verde) e **"Recrutar para o Esquadrão"** (ativo em dourado).
    - Trava de capacidade: Impede recrutamento se o esquadrão já possuir 15 agentes.

---

### 5.7. Missões e Combate Tático (`missions_page.dart`)
- **Propósito:** Modo de jogo estratégico por rodadas onde os agentes do esquadrão enfrentam crises e ameaças.
- **Regras do Modo de Missão:**
  - Exige esquadrão com pelo menos 5 agentes.
  - Gera dinamicamente entre 3 e 5 rodadas (`MissionRound`).
  - Cada rodada sorteia:
    - Um **Atributo Disputado** aleatório (Intelligence, Strength, Speed, Durability, Power ou Combat).
    - Um **Agente Inimigo** sorteado via `getRandomHero(excludeIds: squadIds)` garantindo que não seja membro do esquadrão.
  - Regra de seleção: Cada agente do esquadrão só pode ser escalado em **1 rodada por missão**.
- **Widgets de Layout e Dinâmica do Combate:**
  - **Progresso de Rodadas:** `Row` no topo renderizando indicadores circulares coloridos (Azul = Atual, Verde = Vitória, Vermelho = Derrota, Cinza = Pendente).
  - **Arena de Confronto:**
    - `Row` dividida em duas colunas de combatentes:
      - Coluna da Esquerda: Agente Selecionado do Jogador.
      - Centro: Badge com o atributo em disputa (ex: `🔥 COMBAT`) e ícone `VS`.
      - Coluna da Direita: Agente Inimigo.
    - Se a rodada ainda não foi resolvida, exibe seletor horizontal (`ListView.separated`) para o jogador escolher um agente disponível do seu esquadrão.
  - **Resolução da Rodada (`_resolveRound`):**
    - Compara `heroStat` contra `enemyStat`.
    - Determina `VICTORY`, `DEFEAT` ou `DRAW`.
    - Bloqueia o agente usado adicionando-o a `_usedHeroIds`.
  - **Encerramento da Missão (`_finishMission`):**
    - Se o total de vitórias for superior a 50% dos rounds:
      - Sorteia um dos heróis participantes para ganhar **+1 ponto permanente** no powerstat disputado (`hero.copyWith(...)`).
      - Salva a evolução no banco SQLite via `repo.updateSquadHero(upgradedHero)`.
      - Abre `AwesomeDialog(dialogType: DialogType.success)` informando o herói evoluído e a recompensa.
    - Em caso de derrota, exibe `AwesomeDialog(dialogType: DialogType.error)`.

---

## 6. Resumo das Bibliotecas e Dependências Externas

| Biblioteca | Versão | Finalidade Principal |
|---|---|---|
| `provider` | ^6.1.2 | Injeção de dependências e gerenciamento de estado |
| `sqflite` | ^2.4.1 | Persistência local SQLite para cache e esquadrão |
| `path` | ^1.9.0 | Manipulação de caminhos de arquivos para o banco |
| `http` | ^1.2.2 | Requisições HTTP REST com timeouts e tratamento |
| `infinite_scroll_pagination` | ^4.1.0 | Paginação com carregamento sob demanda no catálogo |
| `cached_network_image` | ^3.4.1 | Download, cache e exibição de imagens remotas |
| `primer_progress_bar` | ^0.2.1 | Barras de progresso com design segmentado |
| `awesome_dialog` | ^3.2.1 | Diálogos modais animados para confirmações e missões |
| `shared_preferences` | ^2.3.3 | Armazenamento do timestamp do Contrato Diário |
| `flutter_test` | SDK | Testes unitários do modelo e regras de combate |

---

## 7. Garantia de Funcionamento Offline

1. **Zero dependência de conexão:** O aplicativo possui `db.json` embutido nos assets com centenas de heróis pré-configurados.
2. **Resiliência do Repositório:** Qualquer chamada de rede que falhe cai automaticamente no fallback do SQLite.
3. **Persistência de Progresso:** Todos os recrutamentos, dispensas e atributos evoluídos em missões são gravados localmente no SQLite do dispositivo, preservando os dados mesmo após fechar o aplicativo.
