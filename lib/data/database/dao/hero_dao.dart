import 'package:sqflite/sqflite.dart';
import '../../../domain/hero_model.dart';
import '../app_database.dart';

class HeroDao {
  final AppDatabase appDatabase;

  HeroDao({required this.appDatabase});

  // ==========================================
  // OPERAÇÕES DE CACHE (CATÁLOGO GERAL)
  // ==========================================

  /// Insere uma lista de heróis no cache (usado ao ler da API)
  Future<void> insertHeroes(List<HeroModel> heroes) async {
    final db = await appDatabase.database;
    final batch = db.batch();
    for (var hero in heroes) {
      batch.insert(
        AppDatabase.tableHeroesCache,
        hero.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  /// Retorna heróis paginados do cache offline
  Future<List<HeroModel>> getCachedHeroes({int limit = 10, int offset = 0}) async {
    final db = await appDatabase.database;
    final maps = await db.query(
      AppDatabase.tableHeroesCache,
      limit: limit,
      offset: offset,
      orderBy: 'id ASC',
    );
    return maps.map((map) => HeroModel.fromMap(map)).toList();
  }

  /// Busca um herói específico pelo ID no cache
  Future<HeroModel?> getCachedHeroById(int id) async {
    final db = await appDatabase.database;
    final maps = await db.query(
      AppDatabase.tableHeroesCache,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return HeroModel.fromMap(maps.first);
    }
    return null;
  }

  /// Retorna o total de heróis que já estão no cache
  Future<int> getCachedHeroesCount() async {
    final db = await appDatabase.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM ${AppDatabase.tableHeroesCache}');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Retorna um herói aleatório do cache local excluindo IDs específicos (ex: membros do esquadrão)
  Future<HeroModel?> getRandomCachedHero({List<int> excludeIds = const []}) async {
    final db = await appDatabase.database;
    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (excludeIds.isNotEmpty) {
      final placeholders = List.filled(excludeIds.length, '?').join(',');
      whereClause = 'WHERE id NOT IN ($placeholders)';
      whereArgs = excludeIds;
    }

    final maps = await db.rawQuery(
      'SELECT * FROM ${AppDatabase.tableHeroesCache} $whereClause ORDER BY RANDOM() LIMIT 1',
      whereArgs,
    );

    if (maps.isNotEmpty) {
      return HeroModel.fromMap(maps.first);
    }
    return null;
  }

  // ==========================================
  // OPERAÇÕES DO ESQUADRÃO (ATÉ 15 MEMBROS)
  // ==========================================

  /// Retorna todos os membros do esquadrão
  Future<List<HeroModel>> getSquadMembers() async {
    final db = await appDatabase.database;
    final maps = await db.query(AppDatabase.tableSquad, orderBy: 'name ASC');
    return maps.map((map) => HeroModel.fromMap(map)).toList();
  }

  /// Retorna a quantidade de agentes atualmente no esquadrão
  Future<int> getSquadCount() async {
    final db = await appDatabase.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM ${AppDatabase.tableSquad}');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Verifica se um herói já foi recrutado para o esquadrão
  Future<bool> isHeroInSquad(int heroId) async {
    final db = await appDatabase.database;
    final maps = await db.query(
      AppDatabase.tableSquad,
      where: 'id = ?',
      whereArgs: [heroId],
    );
    return maps.isNotEmpty;
  }

  /// Adiciona um agente ao esquadrão (com trava de segurança para máx 15)
  Future<bool> recruitHero(HeroModel hero) async {
    final count = await getSquadCount();
    if (count >= 15) {
      return false; // Esquadrão já está cheio!
    }
    final db = await appDatabase.database;
    await db.insert(
      AppDatabase.tableSquad,
      hero.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return true;
  }

  /// Remove (dispensa) um agente do esquadrão
  Future<void> dismissHero(int heroId) async {
    final db = await appDatabase.database;
    await db.delete(
      AppDatabase.tableSquad,
      where: 'id = ?',
      whereArgs: [heroId],
    );
  }

  /// Atualiza os dados de um agente do esquadrão (ex: +1 powerstat ganho na Missão)
  Future<void> updateSquadHero(HeroModel hero) async {
    final db = await appDatabase.database;
    await db.update(
      AppDatabase.tableSquad,
      hero.toMap(),
      where: 'id = ?',
      whereArgs: [hero.id],
    );
  }
}
