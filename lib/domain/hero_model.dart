class HeroModel {
  final int id;
  final String name;
  final String? slug;
  
  // Powerstats (atributos de combate)
  final int intelligence;
  final int strength;
  final int speed;
  final int durability;
  final int power;
  final int combat;

  // Imagens
  final String? imageUrlSmall;
  final String? imageUrlLarge;

  // Detalhes de Aparência & Biografia
  final String? gender;
  final String? race;
  final String? height;
  final String? weight;
  final String? alignment;
  final String? publisher;
  final String? fullName;
  final String? occupation;

  const HeroModel({
    required this.id,
    required this.name,
    this.slug,
    required this.intelligence,
    required this.strength,
    required this.speed,
    required this.durability,
    required this.power,
    required this.combat,
    this.imageUrlSmall,
    this.imageUrlLarge,
    this.gender,
    this.race,
    this.height,
    this.weight,
    this.alignment,
    this.publisher,
    this.fullName,
    this.occupation,
  });

  /// Retorna o valor de um atributo específico pelo nome (útil na Missão)
  int getStatByName(String statName) {
    switch (statName.toLowerCase()) {
      case 'intelligence':
        return intelligence;
      case 'strength':
        return strength;
      case 'speed':
        return speed;
      case 'durability':
        return durability;
      case 'power':
        return power;
      case 'combat':
        return combat;
      default:
        return 0;
    }
  }

  /// Retorna o nome e valor do maior atributo (exigido na tela "Meu Esquadrão")
  String get highestStat {
    final stats = {
      'Intelligence': intelligence,
      'Strength': strength,
      'Speed': speed,
      'Durability': durability,
      'Power': power,
      'Combat': combat,
    };
    var highest = stats.entries.first;
    for (var entry in stats.entries) {
      if (entry.value > highest.value) {
        highest = entry;
      }
    }
    return '${highest.key}: ${highest.value}';
  }

  /// Permite criar uma cópia com atributos modificados (+1 ao vencer missão)
  HeroModel copyWith({
    int? id,
    String? name,
    String? slug,
    int? intelligence,
    int? strength,
    int? speed,
    int? durability,
    int? power,
    int? combat,
    String? imageUrlSmall,
    String? imageUrlLarge,
    String? gender,
    String? race,
    String? height,
    String? weight,
    String? alignment,
    String? publisher,
    String? fullName,
    String? occupation,
  }) {
    return HeroModel(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      intelligence: intelligence ?? this.intelligence,
      strength: strength ?? this.strength,
      speed: speed ?? this.speed,
      durability: durability ?? this.durability,
      power: power ?? this.power,
      combat: combat ?? this.combat,
      imageUrlSmall: imageUrlSmall ?? this.imageUrlSmall,
      imageUrlLarge: imageUrlLarge ?? this.imageUrlLarge,
      gender: gender ?? this.gender,
      race: race ?? this.race,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      alignment: alignment ?? this.alignment,
      publisher: publisher ?? this.publisher,
      fullName: fullName ?? this.fullName,
      occupation: occupation ?? this.occupation,
    );
  }

  /// Construtor a partir de Map (usado para converter JSON da API e registros do SQLite)
  factory HeroModel.fromMap(Map<String, dynamic> map) {
    // Tratamento para caso o mapa venha diretamente da API ou do SQLite local
    final powerstats = map['powerstats'] is Map<String, dynamic>
        ? map['powerstats'] as Map<String, dynamic>
        : null;

    final images = map['images'] is Map<String, dynamic>
        ? map['images'] as Map<String, dynamic>
        : null;

    final appearance = map['appearance'] is Map<String, dynamic>
        ? map['appearance'] as Map<String, dynamic>
        : null;

    final biography = map['biography'] is Map<String, dynamic>
        ? map['biography'] as Map<String, dynamic>
        : null;

    final work = map['work'] is Map<String, dynamic>
        ? map['work'] as Map<String, dynamic>
        : null;

    return HeroModel(
      id: map['id'] is int ? map['id'] : int.tryParse(map['id'].toString()) ?? 0,
      name: map['name'] ?? '',
      slug: map['slug'],
      intelligence: (powerstats?['intelligence'] ?? map['intelligence'] ?? 0) as int,
      strength: (powerstats?['strength'] ?? map['strength'] ?? 0) as int,
      speed: (powerstats?['speed'] ?? map['speed'] ?? 0) as int,
      durability: (powerstats?['durability'] ?? map['durability'] ?? 0) as int,
      power: (powerstats?['power'] ?? map['power'] ?? 0) as int,
      combat: (powerstats?['combat'] ?? map['combat'] ?? 0) as int,
      imageUrlSmall: images?['sm'] ?? map['image_url_small'] ?? images?['xs'],
      imageUrlLarge: images?['lg'] ?? map['image_url_large'] ?? images?['md'],
      gender: appearance?['gender'] ?? map['gender'],
      race: appearance?['race'] ?? map['race'],
      height: (appearance?['height'] is List)
          ? (appearance!['height'] as List).join(' / ')
          : map['height'],
      weight: (appearance?['weight'] is List)
          ? (appearance!['weight'] as List).join(' / ')
          : map['weight'],
      alignment: biography?['alignment'] ?? map['alignment'],
      publisher: biography?['publisher'] ?? map['publisher'],
      fullName: biography?['fullName'] ?? map['full_name'],
      occupation: work?['occupation'] ?? map['occupation'],
    );
  }

  /// Converte para Map para salvar no SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'intelligence': intelligence,
      'strength': strength,
      'speed': speed,
      'durability': durability,
      'power': power,
      'combat': combat,
      'image_url_small': imageUrlSmall,
      'image_url_large': imageUrlLarge,
      'gender': gender,
      'race': race,
      'height': height,
      'weight': weight,
      'alignment': alignment,
      'publisher': publisher,
      'full_name': fullName,
      'occupation': occupation,
    };
  }
}
