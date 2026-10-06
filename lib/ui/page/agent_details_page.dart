import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:primer_progress_bar/primer_progress_bar.dart';
import 'package:provider/provider.dart';

import '../../data/repository/hero_repository.dart';
import '../../domain/hero_model.dart';

class AgentDetailsPage extends StatefulWidget {
  final HeroModel hero;

  const AgentDetailsPage({super.key, required this.hero});

  @override
  State<AgentDetailsPage> createState() => _AgentDetailsPageState();
}

class _AgentDetailsPageState extends State<AgentDetailsPage> {
  late Future<HeroModel?> _heroFuture;

  @override
  void initState() {
    super.initState();
    // Busca preferencialmente da API, com fallback no SQLite local
    final repo = Provider.of<HeroRepository>(context, listen: false);
    _heroFuture = repo.getHeroDetails(widget.hero.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: FutureBuilder<HeroModel?>(
        future: _heroFuture,
        initialData: widget.hero, // Exibição instantânea usando o modelo que já temos
        builder: (context, snapshot) {
          final hero = snapshot.data ?? widget.hero;

          return CustomScrollView(
            slivers: [
              // Barra Superior Dinâmica com Imagem em Alta Resolução
              SliverAppBar(
                expandedHeight: 380,
                pinned: true,
                backgroundColor: const Color(0xFF1E293B),
                iconTheme: const IconThemeData(color: Colors.white),
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    hero.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(color: Colors.black, blurRadius: 8),
                      ],
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Imagem HD com cached_network_image
                      hero.imageUrlLarge != null && hero.imageUrlLarge!.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: hero.imageUrlLarge!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: const Color(0xFF1E293B),
                                child: const Center(
                                  child: CircularProgressIndicator(color: Colors.blueAccent),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: const Color(0xFF1E293B),
                                child: const Icon(Icons.person, size: 80, color: Colors.white24),
                              ),
                            )
                          : Container(
                              color: const Color(0xFF1E293B),
                              child: const Icon(Icons.person, size: 80, color: Colors.white24),
                            ),

                      // Gradiente escuro para legibilidade do texto e transição suave
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Color(0x880F172A),
                              Color(0xFF0F172A),
                            ],
                            stops: [0.5, 0.8, 1.0],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Conteúdo: Powerstats e Detalhes
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ==========================================
                      // SEÇÃO 1: POWERSTATS (com primer_progress_bar)
                      // ==========================================
                      const Text(
                        "Atributos de Combate (Powerstats)",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildStatsCard(hero),
                      const SizedBox(height: 24),

                      // ==========================================
                      // SEÇÃO 2: BIOGRAFIA
                      // ==========================================
                      const Text(
                        "Biografia & Identidade",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoCard([
                        _InfoItem(label: "Nome Completo", value: hero.fullName ?? "Desconhecido"),
                        _InfoItem(label: "Editora", value: hero.publisher ?? "Independente"),
                        _InfoItem(
                          label: "Alinhamento",
                          value: (hero.alignment ?? "Neutro").toUpperCase(),
                          highlightColor: hero.alignment == "good"
                              ? Colors.greenAccent
                              : (hero.alignment == "bad" ? Colors.redAccent : Colors.amberAccent),
                        ),
                        _InfoItem(label: "Ocupação", value: hero.occupation ?? "Não informada"),
                      ]),
                      const SizedBox(height: 24),

                      // ==========================================
                      // SEÇÃO 3: APARÊNCIA
                      // ==========================================
                      const Text(
                        "Aparência Física",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoCard([
                        _InfoItem(label: "Gênero", value: hero.gender ?? "N/A"),
                        _InfoItem(label: "Raça", value: hero.race ?? "Desconhecida"),
                        _InfoItem(label: "Altura", value: hero.height ?? "N/A"),
                        _InfoItem(label: "Peso", value: hero.weight ?? "N/A"),
                      ]),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Card que desenha as barras do primer_progress_bar para cada powerstat
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
          _buildSinglePrimerBar("Intelligence", hero.intelligence, Colors.blueAccent),
          const SizedBox(height: 12),
          _buildSinglePrimerBar("Strength", hero.strength, Colors.orangeAccent),
          const SizedBox(height: 12),
          _buildSinglePrimerBar("Speed", hero.speed, Colors.amberAccent),
          const SizedBox(height: 12),
          _buildSinglePrimerBar("Durability", hero.durability, Colors.tealAccent),
          const SizedBox(height: 12),
          _buildSinglePrimerBar("Power", hero.power, Colors.purpleAccent),
          const SizedBox(height: 12),
          _buildSinglePrimerBar("Combat", hero.combat, Colors.redAccent),
        ],
      ),
    );
  }

  /// Constrói uma barra individual do PrimerProgressBar com legenda
  Widget _buildSinglePrimerBar(String name, int value, Color color) {
    // Garante que o valor fique entre 0 e 100 para o cálculo correto da barra
    final clampedValue = value.clamp(0, 100);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
            ),
            Text(
              "$value / 100",
              style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: PrimerProgressBar(
            segments: [
              Segment(
                value: clampedValue,
                color: color,
                label: Text(name),
                valueLabel: Text("$clampedValue%"),
              ),
            ],
            maxTotalValue: 100,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(List<_InfoItem> items) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        children: items.map((item) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item.label,
                  style: const TextStyle(color: Colors.white54, fontSize: 14),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.value,
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      color: item.highlightColor ?? Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _InfoItem {
  final String label;
  final String value;
  final Color? highlightColor;

  _InfoItem({required this.label, required this.value, this.highlightColor});
}
