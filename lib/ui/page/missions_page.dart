import 'dart:math';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/repository/hero_repository.dart';
import '../../domain/hero_model.dart';

/// Modelo de dados para representar uma rodada da missão
class MissionRound {
  final int roundNumber;
  final String statName;
  final HeroModel enemy;
  HeroModel? selectedHero;
  String? result; // 'VICTORY', 'DEFEAT', 'DRAW'

  MissionRound({
    required this.roundNumber,
    required this.statName,
    required this.enemy,
  });
}

class MissionsPage extends StatefulWidget {
  const MissionsPage({super.key});

  @override
  State<MissionsPage> createState() => _MissionsPageState();
}

class _MissionsPageState extends State<MissionsPage> {
  bool _isLoading = true;
  List<HeroModel> _squad = [];
  
  // Estado da missão ativa
  bool _missionActive = false;
  List<MissionRound> _rounds = [];
  int _currentRoundIndex = 0;
  final Set<int> _usedHeroIds = {}; // Heróis que já lutaram nesta missão
  HeroModel? _selectedHeroForCurrentRound;
  bool _roundResolved = false;

  final List<String> _availableStats = [
    'Intelligence',
    'Strength',
    'Speed',
    'Durability',
    'Power',
    'Combat',
  ];

  @override
  void initState() {
    super.initState();
    _checkSquad();
  }

  Future<void> _checkSquad() async {
    setState(() => _isLoading = true);
    final repo = Provider.of<HeroRepository>(context, listen: false);
    final squad = await repo.getSquadMembers();
    if (mounted) {
      setState(() {
        _squad = squad;
        _isLoading = false;
      });
    }
  }

  /// Gera e inicia a missão tática
  Future<void> _startMission() async {
    if (_squad.length < 5) return;

    setState(() => _isLoading = true);
    final repo = Provider.of<HeroRepository>(context, listen: false);
    final random = Random();

    // Sorteia de 3 a 5 rounds
    final totalRounds = random.nextInt(3) + 3; // 3, 4 ou 5
    final List<MissionRound> generatedRounds = [];

    final squadIds = _squad.map((h) => h.id).toList();

    for (int i = 0; i < totalRounds; i++) {
      final stat = _availableStats[random.nextInt(_availableStats.length)];
      // Sorteia um inimigo garantindo que NÃO seja membro do esquadrão
      final enemy = await repo.getRandomHero(excludeIds: squadIds);

      if (enemy != null) {
        generatedRounds.add(
          MissionRound(
            roundNumber: i + 1,
            statName: stat,
            enemy: enemy,
          ),
        );
      }
    }

    if (generatedRounds.isEmpty) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erro ao gerar missão. Tente novamente.")),
        );
      }
      return;
    }

    setState(() {
      _rounds = generatedRounds;
      _currentRoundIndex = 0;
      _usedHeroIds.clear();
      _selectedHeroForCurrentRound = null;
      _roundResolved = false;
      _missionActive = true;
      _isLoading = false;
    });
  }

  /// Resolve o combate da rodada atual
  void _resolveRound() {
    if (_selectedHeroForCurrentRound == null) return;

    final round = _rounds[_currentRoundIndex];
    final heroStat = _selectedHeroForCurrentRound!.getStatByName(round.statName);
    final enemyStat = round.enemy.getStatByName(round.statName);

    String result;
    if (heroStat > enemyStat) {
      result = 'VICTORY';
    } else if (heroStat < enemyStat) {
      result = 'DEFEAT';
    } else {
      result = 'DRAW';
    }

    setState(() {
      round.selectedHero = _selectedHeroForCurrentRound;
      round.result = result;
      _usedHeroIds.add(_selectedHeroForCurrentRound!.id);
      _roundResolved = true;
    });
  }

  /// Avança para o próximo round ou finaliza a missão
  void _nextRoundOrFinish() {
    if (_currentRoundIndex + 1 < _rounds.length) {
      setState(() {
        _currentRoundIndex++;
        _selectedHeroForCurrentRound = null;
        _roundResolved = false;
      });
    } else {
      _finishMission();
    }
  }

  /// Encerra a missão e exibe o AwesomeDialog com recompensas
  Future<void> _finishMission() async {
    final victories = _rounds.where((r) => r.result == 'VICTORY').length;
    final defeats = _rounds.where((r) => r.result == 'DEFEAT').length;
    final isSuccess = victories > (_rounds.length / 2);

    final repo = Provider.of<HeroRepository>(context, listen: false);

    if (isSuccess) {
      // Sorteia um dos heróis do esquadrão participantes para ganhar +1 em um powerstat
      final heroesInMission = _rounds
          .where((r) => r.selectedHero != null)
          .map((r) => r.selectedHero!)
          .toList();

      final heroToUpgrade = heroesInMission.isNotEmpty
          ? heroesInMission[Random().nextInt(heroesInMission.length)]
          : _squad.first;

      final random = Random();
      final statIndex = random.nextInt(6);
      HeroModel upgradedHero = heroToUpgrade;
      String upgradedStatName = '';

      switch (statIndex) {
        case 0:
          upgradedHero = heroToUpgrade.copyWith(intelligence: heroToUpgrade.intelligence + 1);
          upgradedStatName = "Intelligence (+1)";
          break;
        case 1:
          upgradedHero = heroToUpgrade.copyWith(strength: heroToUpgrade.strength + 1);
          upgradedStatName = "Strength (+1)";
          break;
        case 2:
          upgradedHero = heroToUpgrade.copyWith(speed: heroToUpgrade.speed + 1);
          upgradedStatName = "Speed (+1)";
          break;
        case 3:
          upgradedHero = heroToUpgrade.copyWith(durability: heroToUpgrade.durability + 1);
          upgradedStatName = "Durability (+1)";
          break;
        case 4:
          upgradedHero = heroToUpgrade.copyWith(power: heroToUpgrade.power + 1);
          upgradedStatName = "Power (+1)";
          break;
        case 5:
          upgradedHero = heroToUpgrade.copyWith(combat: heroToUpgrade.combat + 1);
          upgradedStatName = "Combat (+1)";
          break;
      }

      // Salva o upgrade no SQLite
      await repo.updateSquadHero(upgradedHero);
      await _checkSquad(); // Atualiza a lista local

      if (!mounted) return;

      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.scale,
        title: 'Missão Cumprida!',
        desc: 'Vitórias: $victories | Derrotas: $defeats\n\n${upgradedHero.name} se destacou no combate e evoluiu seu atributo $upgradedStatName!',
        btnOkText: 'Receber Recompensa',
        btnOkColor: Colors.green,
        btnOkOnPress: () {
          setState(() {
            _missionActive = false;
          });
        },
      ).show();
    } else {
      if (!mounted) return;

      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.scale,
        title: 'Operação Fracassada!',
        desc: 'Vitórias: $victories | Derrotas: $defeats\n\nO esquadrão não conseguiu conter a crise. Reorganize seus agentes e tente novamente!',
        btnOkText: 'Voltar ao Comando',
        btnOkColor: Colors.redAccent,
        btnOkOnPress: () {
          setState(() {
            _missionActive = false;
          });
        },
      ).show();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text(
          "Central de Missões",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1E293B),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 2,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.redAccent))
          : !_missionActive
              ? _buildPreMissionScreen()
              : _buildBattleScreen(),
    );
  }

  /// Tela inicial de briefing da Missão (com checagem de 5 agentes)
  Widget _buildPreMissionScreen() {
    final hasEnoughAgents = _squad.length >= 5;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: hasEnoughAgents ? Colors.redAccent.withOpacity(0.5) : Colors.grey.withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.crisis_alert_rounded,
                  size: 80,
                  color: hasEnoughAgents ? Colors.redAccent : Colors.grey,
                ),
                const SizedBox(height: 16),
                const Text(
                  "Desafio de Crise Tática",
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  "Enfrente uma série de 3 a 5 rounds contra ameaças do sistema. Cada agente só pode lutar uma vez.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: hasEnoughAgents ? Colors.green.withOpacity(0.15) : Colors.red.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: hasEnoughAgents ? Colors.greenAccent : Colors.redAccent),
                  ),
                  child: Text(
                    hasEnoughAgents
                        ? "Agentes Disponíveis: ${_squad.length} / 15 (Pronto para Combate)"
                        : "Requer no mínimo 5 agentes no esquadrão! (Você tem ${_squad.length})",
                    style: TextStyle(
                      color: hasEnoughAgents ? Colors.greenAccent : Colors.redAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: hasEnoughAgents ? _startMission : null,
            icon: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
            label: const Text(
              "INICIAR MISSÃO",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              disabledBackgroundColor: Colors.grey[800],
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
            ),
          ),
        ],
      ),
    );
  }

  /// Tela ativa de Batalha com os Rounds
  Widget _buildBattleScreen() {
    final currentRound = _rounds[_currentRoundIndex];
    final victories = _rounds.where((r) => r.result == 'VICTORY').length;
    final defeats = _rounds.where((r) => r.result == 'DEFEAT').length;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Placar e Indicador de Round
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "ROUND ${currentRound.roundNumber} / ${_rounds.length}",
                  style: const TextStyle(color: Colors.amberAccent, fontSize: 18, fontWeight: FontWeight.w900),
                ),
                Row(
                  children: [
                    _ScoreChip("VITÓRIAS", victories, Colors.greenAccent),
                    const SizedBox(width: 8),
                    _ScoreChip("DERROTAS", defeats, Colors.redAccent),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Card do Inimigo da Rodada
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: currentRound.enemy.imageUrlSmall != null
                            ? CachedNetworkImage(
                                imageUrl: currentRound.enemy.imageUrlSmall!,
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                              )
                            : const Icon(Icons.person, size: 70, color: Colors.white24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("INIMIGO DA RODADA", style: TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                            Text(
                              currentRound.enemy.name,
                              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _roundResolved
                                  ? "Atributo: ${currentRound.enemy.getStatByName(currentRound.statName)}"
                                  : "Atributos Ocultos",
                              style: TextStyle(
                                color: _roundResolved ? Colors.amberAccent : Colors.grey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Color(0xFF334155), height: 24),
                  // Atributo exigido na rodada
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.bolt, color: Colors.amberAccent),
                      const SizedBox(width: 6),
                      Text(
                        "DISPUTA: ${currentRound.statName.toUpperCase()}",
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Resultado da rodada (após resolver)
            if (_roundResolved) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: currentRound.result == 'VICTORY'
                      ? Colors.green.withOpacity(0.2)
                      : (currentRound.result == 'DEFEAT' ? Colors.red.withOpacity(0.2) : Colors.amber.withOpacity(0.2)),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: currentRound.result == 'VICTORY'
                        ? Colors.greenAccent
                        : (currentRound.result == 'DEFEAT' ? Colors.redAccent : Colors.amberAccent),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      currentRound.result == 'VICTORY'
                          ? "VITÓRIA NA RODADA!"
                          : (currentRound.result == 'DEFEAT' ? "FALHA NA RODADA!" : "EMPATE TÁTICO!"),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: currentRound.result == 'VICTORY'
                            ? Colors.greenAccent
                            : (currentRound.result == 'DEFEAT' ? Colors.redAccent : Colors.amberAccent),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${_selectedHeroForCurrentRound!.name} (${_selectedHeroForCurrentRound!.getStatByName(currentRound.statName)}) vs ${currentRound.enemy.name} (${currentRound.enemy.getStatByName(currentRound.statName)})",
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _nextRoundOrFinish,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  _currentRoundIndex + 1 < _rounds.length ? "PRÓXIMO ROUND" : "VER SUMÁRIO DA MISSÃO",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Seção de Escalação Tática (Grid 3x5 de Agentes com miniatura circular)
            const Text(
              "Escalar Agente para a Rodada:",
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              "Selecione um agente disponível. Cada agente só pode ser enviado 1 vez por missão.",
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
            const SizedBox(height: 12),

            // Grid 3x5 de agentes
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.85,
              ),
              itemCount: _squad.length,
              itemBuilder: (context, index) {
                final hero = _squad[index];
                final isUsed = _usedHeroIds.contains(hero.id);
                final isSelected = _selectedHeroForCurrentRound?.id == hero.id;

                return GestureDetector(
                  onTap: (_roundResolved || isUsed)
                      ? null
                      : () {
                          setState(() {
                            _selectedHeroForCurrentRound = hero;
                          });
                        },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.blue.withOpacity(0.3)
                          : (isUsed ? Colors.black26 : const Color(0xFF1E293B)),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? Colors.blueAccent
                            : (isUsed ? Colors.transparent : const Color(0xFF334155)),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Miniatura circular
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            CircleAvatar(
                              radius: 26,
                              backgroundColor: const Color(0xFF334155),
                              backgroundImage: hero.imageUrlSmall != null
                                  ? CachedNetworkImageProvider(hero.imageUrlSmall!)
                                  : null,
                              child: hero.imageUrlSmall == null
                                  ? const Icon(Icons.person, color: Colors.white54)
                                  : null,
                            ),
                            if (isUsed)
                              Container(
                                width: 52,
                                height: 52,
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.check, color: Colors.white70),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Text(
                            hero.name,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isUsed ? Colors.grey : Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          isUsed ? "Em combate" : "${currentRound.statName.substring(0, 3)}: ${hero.getStatByName(currentRound.statName)}",
                          style: TextStyle(
                            color: isUsed ? Colors.grey[600] : Colors.amberAccent,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // Botão Confirmar Agente para a Rodada
            if (!_roundResolved)
              ElevatedButton.icon(
                onPressed: _selectedHeroForCurrentRound != null ? _resolveRound : null,
                icon: const Icon(Icons.security, color: Colors.white),
                label: Text(
                  _selectedHeroForCurrentRound != null
                      ? "CONFIRMAR ${_selectedHeroForCurrentRound!.name.toUpperCase()}"
                      : "SELECIONE UM AGENTE NO GRID",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  disabledBackgroundColor: Colors.grey[800],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ScoreChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _ScoreChip(this.label, this.count, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        "$label: $count",
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}
