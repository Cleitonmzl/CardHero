import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/repository/hero_repository.dart';
import '../../domain/hero_model.dart';
import '../widgets/hero_card.dart';
import 'my_agent_details_page.dart';

class MySquadPage extends StatefulWidget {
  const MySquadPage({super.key});

  @override
  State<MySquadPage> createState() => _MySquadPageState();
}

class _MySquadPageState extends State<MySquadPage> {
  List<HeroModel> _squad = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSquad();
  }

  Future<void> _loadSquad() async {
    setState(() => _isLoading = true);
    final repo = Provider.of<HeroRepository>(context, listen: false);
    await repo.ensureInitialSquad();
    final members = await repo.getSquadMembers();
    if (mounted) {
      setState(() {
        _squad = members;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text(
          "Meu Esquadrão",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1E293B),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 2,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.greenAccent),
                ),
                child: Text(
                  "${_squad.length} / 15",
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.greenAccent),
            )
          : _squad.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shield_outlined, size: 70, color: Colors.white.withOpacity(0.3)),
                      const SizedBox(height: 16),
                      const Text(
                        "Seu esquadrão ainda está vazio!",
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Recrute novos agentes no Contrato Diário.",
                        style: TextStyle(color: Colors.grey[400], fontSize: 14),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _squad.length,
                  itemBuilder: (context, index) {
                    final hero = _squad[index];
                    return HeroCard(
                      hero: hero,
                      subtitleOverride: "Maior Atributo: ${hero.highestStat}",
                      onTap: () async {
                        // Navega para os detalhes e recarrega se o herói tiver sido dispensado
                        final removed = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MyAgentDetailsPage(hero: hero),
                          ),
                        );
                        if (removed == true) {
                          _loadSquad();
                        }
                      },
                    );
                  },
                ),
    );
  }
}
