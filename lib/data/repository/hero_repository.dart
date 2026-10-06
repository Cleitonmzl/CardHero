import 'dart:math';
import '../../../domain/hero_model.dart';
import '../database/dao/hero_dao.dart';
import '../network/client/api_client.dart';

class HeroRepository {
  final ApiClient apiClient;
  final HeroDao heroDao;

  HeroRepository({
    required this.apiClient,
    required this.heroDao,
  });

  /// Busca heróis paginados com estratégia Offline-First
  Future<List<HeroModel>> getHeroes({required int page, required int limit}) async {
    final offset = (page - 1) * limit;

    try {
      // 1. Tenta buscar da API remota
      final remoteHeroes = await apiClient.getHeroes(page: page, limit: limit);

      if (remoteHeroes.isNotEmpty) {
        // 2. Salva em cache local no SQLite
        await heroDao.insertHeroes(remoteHeroes);
        return remoteHeroes;
      }
    } catch (_) {
      // Falha de rede (offline ou servidor indisponível): recupera do cache local
    }

    // 3. Fallback: Lê do banco de dados local SQLite
    final localHeroes = await heroDao.getCachedHeroes(limit: limit, offset: offset);
    return localHeroes;
  }

  /// Busca detalhes do herói (prioriza API, fallback no SQLite)
  Future<HeroModel?> getHeroDetails(int id) async {
    try {
      final remote = await apiClient.getHeroById(id);
      if (remote != null) {
        await heroDao.insertHeroes([remote]);
        return remote;
      }
    } catch (_) {}

    return await heroDao.getCachedHeroById(id);
  }

  // ==========================
  // OPERAÇÕES DO ESQUADRÃO
  // ==========================

  Future<List<HeroModel>> getSquadMembers() => heroDao.getSquadMembers();

  Future<int> getSquadCount() => heroDao.getSquadCount();

  Future<bool> isHeroInSquad(int heroId) => heroDao.isHeroInSquad(heroId);

  Future<bool> recruitHero(HeroModel hero) => heroDao.recruitHero(hero);

  Future<void> dismissHero(int heroId) => heroDao.dismissHero(heroId);

  Future<void> updateSquadHero(HeroModel hero) => heroDao.updateSquadHero(hero);

  /// Sorteia um herói aleatório (usado para Contrato Diário e Inimigos da Missão)
  Future<HeroModel?> getRandomHero({List<int> excludeIds = const []}) async {
    final totalCached = await heroDao.getCachedHeroesCount();

    // Se temos heróis no cache local, sorteamos de lá
    if (totalCached > 0) {
      final random = Random();
      // Tenta até 10 vezes sortear um que não esteja na lista de excluídos
      for (int i = 0; i < 10; i++) {
        final randomOffset = random.nextInt(totalCached);
        final list = await heroDao.getCachedHeroes(limit: 1, offset: randomOffset);
        if (list.isNotEmpty && !excludeIds.contains(list.first.id)) {
          return list.first;
        }
      }
    }

    // Se não encontrou no cache ou ainda não há cache, busca da API
    try {
      final randomPage = Random().nextInt(50) + 1;
      final heroes = await apiClient.getHeroes(page: randomPage, limit: 10);
      if (heroes.isNotEmpty) {
        await heroDao.insertHeroes(heroes);
        final filtered = heroes.where((h) => !excludeIds.contains(h.id)).toList();
        if (filtered.isNotEmpty) {
          return filtered[Random().nextInt(filtered.length)];
        }
      }
    } catch (_) {}

    return null;
  }

  /// Garante que o jogador já inicie com 5 agentes no seu inventário/esquadrão
  Future<void> ensureInitialSquad() async {
    final currentCount = await heroDao.getSquadCount();
    if (currentCount >= 5) return;

    final squadMembers = await heroDao.getSquadMembers();
    final squadIds = squadMembers.map((h) => h.id).toSet();
    final needed = 5 - currentCount;

    // 1. Tenta recrutar a partir do cache local SQLite se já houver heróis disponíveis
    final cached = await heroDao.getCachedHeroes(limit: 30);
    final availableCached = cached.where((h) => !squadIds.contains(h.id)).toList();
    for (var hero in availableCached.take(needed)) {
      await heroDao.recruitHero(hero);
      squadIds.add(hero.id);
    }

    if ((await heroDao.getSquadCount()) >= 5) return;

    // 2. Tenta buscar da API remota
    try {
      final remoteHeroes = await apiClient.getHeroes(page: 1, limit: 10);
      if (remoteHeroes.isNotEmpty) {
        await heroDao.insertHeroes(remoteHeroes);
        for (var hero in remoteHeroes) {
          if (!squadIds.contains(hero.id) && (await heroDao.getSquadCount()) < 5) {
            await heroDao.recruitHero(hero);
            squadIds.add(hero.id);
          }
        }
      }
    } catch (_) {}

    if ((await heroDao.getSquadCount()) >= 5) return;

    // 3. Fallback garantido: insere os 5 agentes iniciais clássicos diretamente
    final starterHeroes = _getStarterHeroes();
    await heroDao.insertHeroes(starterHeroes);
    for (var hero in starterHeroes) {
      if (!squadIds.contains(hero.id) && (await heroDao.getSquadCount()) < 5) {
        await heroDao.recruitHero(hero);
        squadIds.add(hero.id);
      }
    }
  }

  /// Lista de 5 agentes iniciais caso o jogador inicie totalmente offline
  List<HeroModel> _getStarterHeroes() {
    return const [
      HeroModel(
        id: 1,
        name: 'A-Bomb',
        slug: '1-a-bomb',
        intelligence: 38,
        strength: 100,
        speed: 17,
        durability: 80,
        power: 24,
        combat: 64,
        imageUrlSmall: 'https://cdn.jsdelivr.net/gh/akabab/superhero-api@0.3.0/api/images/sm/1-a-bomb.jpg',
        imageUrlLarge: 'https://cdn.jsdelivr.net/gh/akabab/superhero-api@0.3.0/api/images/lg/1-a-bomb.jpg',
        gender: 'Male',
        race: 'Human',
        alignment: 'good',
        publisher: 'Marvel Comics',
        fullName: 'Richard Milhouse Jones',
        occupation: 'Musician, adventurer',
      ),
      HeroModel(
        id: 2,
        name: 'Abe Sapien',
        slug: '2-abe-sapien',
        intelligence: 88,
        strength: 28,
        speed: 35,
        durability: 65,
        power: 100,
        combat: 85,
        imageUrlSmall: 'https://cdn.jsdelivr.net/gh/akabab/superhero-api@0.3.0/api/images/sm/2-abe-sapien.jpg',
        imageUrlLarge: 'https://cdn.jsdelivr.net/gh/akabab/superhero-api@0.3.0/api/images/lg/2-abe-sapien.jpg',
        gender: 'Male',
        race: 'Icthyo Sapien',
        alignment: 'good',
        publisher: 'Dark Horse Comics',
        fullName: 'Abraham Sapien',
        occupation: 'Paranormal Investigator',
      ),
      HeroModel(
        id: 3,
        name: 'Abin Sur',
        slug: '3-abin-sur',
        intelligence: 50,
        strength: 90,
        speed: 53,
        durability: 64,
        power: 99,
        combat: 65,
        imageUrlSmall: 'https://cdn.jsdelivr.net/gh/akabab/superhero-api@0.3.0/api/images/sm/3-abin-sur.jpg',
        imageUrlLarge: 'https://cdn.jsdelivr.net/gh/akabab/superhero-api@0.3.0/api/images/lg/3-abin-sur.jpg',
        gender: 'Male',
        race: 'Ungaran',
        alignment: 'good',
        publisher: 'DC Comics',
        fullName: 'Abin Sur',
        occupation: 'Green Lantern',
      ),
      HeroModel(
        id: 4,
        name: 'Abomination',
        slug: '4-abomination',
        intelligence: 63,
        strength: 80,
        speed: 53,
        durability: 90,
        power: 62,
        combat: 95,
        imageUrlSmall: 'https://cdn.jsdelivr.net/gh/akabab/superhero-api@0.3.0/api/images/sm/4-abomination.jpg',
        imageUrlLarge: 'https://cdn.jsdelivr.net/gh/akabab/superhero-api@0.3.0/api/images/lg/4-abomination.jpg',
        gender: 'Male',
        race: 'Human / Radiation',
        alignment: 'bad',
        publisher: 'Marvel Comics',
        fullName: 'Emil Blonsky',
        occupation: 'Ex-Spy',
      ),
      HeroModel(
        id: 5,
        name: 'Abraxas',
        slug: '5-abraxas',
        intelligence: 88,
        strength: 63,
        speed: 83,
        durability: 100,
        power: 100,
        combat: 55,
        imageUrlSmall: 'https://cdn.jsdelivr.net/gh/akabab/superhero-api@0.3.0/api/images/sm/5-abraxas.jpg',
        imageUrlLarge: 'https://cdn.jsdelivr.net/gh/akabab/superhero-api@0.3.0/api/images/lg/5-abraxas.jpg',
        gender: 'Male',
        race: 'Cosmic Entity',
        alignment: 'bad',
        publisher: 'Marvel Comics',
        fullName: 'Abraxas',
        occupation: 'Cosmic Conqueror',
      ),
    ];
  }
}
