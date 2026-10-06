import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/repository/hero_repository.dart';
import '../../domain/hero_model.dart';

class DailyContractPage extends StatefulWidget {
  const DailyContractPage({super.key});

  @override
  State<DailyContractPage> createState() => _DailyContractPageState();
}

class _DailyContractPageState extends State<DailyContractPage> {
  HeroModel? _dailyHero;
  bool _isLoading = true;
  bool _isAlreadyRecruited = false;
  int _squadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadDailyContract();
  }

  /// Gerencia a regra de 1 sorteio por dia usando SharedPreferences
  Future<void> _loadDailyContract() async {
    setState(() => _isLoading = true);

    final repo = Provider.of<HeroRepository>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();

    final today = DateTime.now().toIso8601String().substring(0, 10); // Ex: '2026-10-05'
    final lastDate = prefs.getString('last_contract_date');
    final lastHeroId = prefs.getInt('last_contract_hero_id');

    HeroModel? hero;

    // Se já sorteamos hoje e temos o ID salvo, recuperamos o mesmo herói
    if (lastDate == today && lastHeroId != null) {
      hero = await repo.getHeroDetails(lastHeroId);
    }

    // Se é um novo dia ou ainda não há sorteio salvo:
    if (hero == null) {
      hero = await repo.getRandomHero();
      if (hero != null) {
        await prefs.setString('last_contract_date', today);
        await prefs.setInt('last_contract_hero_id', hero.id);
      }
    }

    // Verifica capacidade do esquadrão e se esse herói já é membro
    if (hero != null) {
      final inSquad = await repo.isHeroInSquad(hero.id);
      final count = await repo.getSquadCount();

      if (mounted) {
        setState(() {
          _dailyHero = hero;
          _isAlreadyRecruited = inSquad;
          _squadCount = count;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Recruta o herói do dia para o esquadrão
  Future<void> _recruit() async {
    if (_dailyHero == null) return;

    final repo = Provider.of<HeroRepository>(context, listen: false);

    if (_squadCount >= 15) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("O esquadrão atingiu a capacidade máxima de 15 agentes!"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final success = await repo.recruitHero(_dailyHero!);
    if (success) {
      setState(() {
        _isAlreadyRecruited = true;
        _squadCount++;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Agente ${_dailyHero!.name} foi recrutado com sucesso!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text(
          "Contrato Diário",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1E293B),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 2,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.amber),
            )
          : _dailyHero == null
              ? const Center(
                  child: Text(
                    "Nenhum contrato disponível no momento.",
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              : SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Contador do Esquadrão
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Convocação do Dia",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _squadCount >= 15 ? Colors.red.withOpacity(0.2) : Colors.blue.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _squadCount >= 15 ? Colors.redAccent : Colors.blueAccent,
                                ),
                              ),
                              child: Text(
                                "Vagas: $_squadCount / 15",
                                style: TextStyle(
                                  color: _squadCount >= 15 ? Colors.redAccent : Colors.blueAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Card Exclusivo do Contrato Diário (Imagem + Nome + Powerstats)
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.amber.withOpacity(0.5), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.amber.withOpacity(0.1),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Imagem do Herói
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
                                child: SizedBox(
                                  height: 260,
                                  child: _dailyHero!.imageUrlLarge != null && _dailyHero!.imageUrlLarge!.isNotEmpty
                                      ? CachedNetworkImage(
                                          imageUrl: _dailyHero!.imageUrlLarge!,
                                          fit: BoxFit.cover,
                                          placeholder: (_, __) => const Center(
                                            child: CircularProgressIndicator(color: Colors.amber),
                                          ),
                                          errorWidget: (_, __, ___) => const Icon(
                                            Icons.person,
                                            size: 80,
                                            color: Colors.white24,
                                          ),
                                        )
                                      : const Icon(Icons.person, size: 80, color: Colors.white24),
                                ),
                              ),

                              // Nome do Herói
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    Text(
                                      _dailyHero!.name,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 16),

                                    // Powerstats simplificados (requisito do Slide 7)
                                    _buildStatRow("Intelligence", _dailyHero!.intelligence, Colors.blueAccent),
                                    _buildStatRow("Strength", _dailyHero!.strength, Colors.orangeAccent),
                                    _buildStatRow("Speed", _dailyHero!.speed, Colors.amberAccent),
                                    _buildStatRow("Durability", _dailyHero!.durability, Colors.tealAccent),
                                    _buildStatRow("Power", _dailyHero!.power, Colors.purpleAccent),
                                    _buildStatRow("Combat", _dailyHero!.combat, Colors.redAccent),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Botão "Recrutar para o Esquadrão"
                        ElevatedButton.icon(
                          onPressed: (_isAlreadyRecruited || _squadCount >= 15) ? null : _recruit,
                          icon: Icon(
                            _isAlreadyRecruited
                                ? Icons.check_circle_rounded
                                : (_squadCount >= 15 ? Icons.block_rounded : Icons.person_add_rounded),
                            color: Colors.white,
                          ),
                          label: Text(
                            _isAlreadyRecruited
                                ? "Já Recrutado"
                                : (_squadCount >= 15 ? "Esquadrão Cheio (15/15)" : "Recrutar para o Esquadrão"),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isAlreadyRecruited
                                ? Colors.grey[700]
                                : (_squadCount >= 15 ? Colors.red[800] : const Color(0xFF10B981)),
                            disabledBackgroundColor: Colors.grey[800],
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildStatRow(String name, int value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: const TextStyle(color: Colors.white70, fontSize: 14)),
          Row(
            children: [
              Container(
                width: 100,
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFF334155),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: (value.clamp(0, 100)) / 100,
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 32,
                child: Text(
                  "$value",
                  textAlign: TextAlign.end,
                  style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
