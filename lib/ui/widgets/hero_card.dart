import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../domain/hero_model.dart';

class HeroCard extends StatelessWidget {
  final HeroModel hero;
  final VoidCallback onTap;
  final String? subtitleOverride; // Para customizar no Esquadrão se quiser

  const HeroCard({
    super.key,
    required this.hero,
    required this.onTap,
    this.subtitleOverride,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1E293B),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF334155), width: 1),
      ),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // 1. Imagem Miniatura com Cache (cached_network_image)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: hero.imageUrlSmall != null && hero.imageUrlSmall!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: hero.imageUrlSmall!,
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 72,
                          height: 72,
                          color: const Color(0xFF334155),
                          child: const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blueAccent),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 72,
                          height: 72,
                          color: const Color(0xFF334155),
                          child: const Icon(Icons.person, color: Colors.white54, size: 36),
                        ),
                      )
                    : Container(
                        width: 72,
                        height: 72,
                        color: const Color(0xFF334155),
                        child: const Icon(Icons.person, color: Colors.white54, size: 36),
                      ),
              ),
              const SizedBox(width: 14),

              // 2. Informações do Herói (Nome, Appearance, Powerstats)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hero.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Aparência (Raça / Gênero / Alinhamento)
                    if (subtitleOverride != null)
                      Text(
                        subtitleOverride!,
                        style: const TextStyle(
                          color: Colors.amberAccent,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      )
                    else
                      Text(
                        "${hero.race ?? 'Desconhecido'} • ${hero.gender ?? 'N/A'}",
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 13,
                        ),
                      ),
                    const SizedBox(height: 8),

                    // Badges dos Powerstats principais (Combate, Força, Inteligência)
                    Row(
                      children: [
                        _StatBadge(
                          icon: Icons.flash_on,
                          color: Colors.orange,
                          label: "STR",
                          value: hero.strength,
                        ),
                        const SizedBox(width: 6),
                        _StatBadge(
                          icon: Icons.psychology,
                          color: Colors.blueAccent,
                          label: "INT",
                          value: hero.intelligence,
                        ),
                        const SizedBox(width: 6),
                        _StatBadge(
                          icon: Icons.sports_martial_arts,
                          color: Colors.redAccent,
                          label: "CMB",
                          value: hero.combat,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white38, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final int value;

  const _StatBadge({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 3),
          Text(
            "$label $value",
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
