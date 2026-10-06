import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:primer_progress_bar/primer_progress_bar.dart';
import 'package:provider/provider.dart';

import '../../data/repository/hero_repository.dart';
import '../../domain/hero_model.dart';

class MyAgentDetailsPage extends StatelessWidget {
  final HeroModel hero;

  const MyAgentDetailsPage({super.key, required this.hero});

  /// Exibe o diálogo de confirmação obrigatório via awesome_dialog
  void _confirmDismiss(BuildContext context) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.bottomSlide,
      title: 'Dispensar Agente?',
      desc: 'Tem certeza que deseja dispensar ${hero.name} do esquadrão? A vaga será liberada.',
      btnCancelText: 'Cancelar',
      btnOkText: 'Dispensar',
      btnOkColor: Colors.redAccent,
      btnCancelOnPress: () {},
      btnOkOnPress: () async {
        final repo = Provider.of<HeroRepository>(context, listen: false);
        await repo.dismissHero(hero.id);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("${hero.name} foi dispensado do esquadrão."),
              backgroundColor: Colors.redAccent,
            ),
          );
          Navigator.pop(context, true); // Retorna true para atualizar a lista
        }
      },
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: CustomScrollView(
        slivers: [
          // Barra de imagem do Agente
          SliverAppBar(
            expandedHeight: 340,
            pinned: true,
            backgroundColor: const Color(0xFF1E293B),
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                hero.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black, blurRadius: 8)],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  hero.imageUrlLarge != null && hero.imageUrlLarge!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: hero.imageUrlLarge!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(color: const Color(0xFF1E293B)),
                          errorWidget: (_, __, ___) => const Icon(Icons.person, size: 80, color: Colors.white24),
                        )
                      : const Icon(Icons.person, size: 80, color: Colors.white24),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0x880F172A), Color(0xFF0F172A)],
                        stops: [0.5, 0.8, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Informações e Botão de Dispensar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Destaque do Maior Atributo
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.greenAccent.withOpacity(0.4)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Colors.greenAccent, size: 28),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Papel Tático Principal",
                              style: TextStyle(color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              hero.highestStat,
                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Powerstats com primer_progress_bar
                  const Text(
                    "Atributos de Combate",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildStatsCard(hero),
                  const SizedBox(height: 20),

                  // Biografia e Identidade
                  const Text(
                    "Informações do Agente",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard([
                    _InfoRow("Nome Completo", hero.fullName ?? "Desconhecido"),
                    _InfoRow("Editora", hero.publisher ?? "Independente"),
                    _InfoRow("Alinhamento", (hero.alignment ?? "Neutro").toUpperCase()),
                    _InfoRow("Gênero", hero.gender ?? "N/A"),
                    _InfoRow("Raça", hero.race ?? "Desconhecida"),
                  ]),
                  const SizedBox(height: 28),

                  // Botão "Dispensar do Esquadrão"
                  ElevatedButton.icon(
                    onPressed: () => _confirmDismiss(context),
                    icon: const Icon(Icons.person_remove_rounded, color: Colors.white),
                    label: const Text(
                      "Dispensar do Esquadrão",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[800],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 3,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(HeroModel hero) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        children: [
          _buildBar("Intelligence", hero.intelligence, Colors.blueAccent),
          const SizedBox(height: 10),
          _buildBar("Strength", hero.strength, Colors.orangeAccent),
          const SizedBox(height: 10),
          _buildBar("Speed", hero.speed, Colors.amberAccent),
          const SizedBox(height: 10),
          _buildBar("Durability", hero.durability, Colors.tealAccent),
          const SizedBox(height: 10),
          _buildBar("Power", hero.power, Colors.purpleAccent),
          const SizedBox(height: 10),
          _buildBar("Combat", hero.combat, Colors.redAccent),
        ],
      ),
    );
  }

  Widget _buildBar(String name, int value, Color color) {
    final clamped = value.clamp(0, 100);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name, style: const TextStyle(color: Colors.white70, fontSize: 13)),
            Text("$value / 100", style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: PrimerProgressBar(
            segments: [
              Segment(
                value: clamped,
                color: color,
                label: Text(name),
                valueLabel: Text("$clamped%"),
              ),
            ],
            maxTotalValue: 100,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(List<_InfoRow> items) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        children: items.map((i) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(i.label, style: const TextStyle(color: Colors.white54, fontSize: 14)),
              Text(i.value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
        )).toList(),
      ),
    );
  }
}

class _InfoRow {
  final String label;
  final String value;
  _InfoRow(this.label, this.value);
}
