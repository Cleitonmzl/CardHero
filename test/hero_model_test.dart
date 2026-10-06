import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_repository_example/domain/hero_model.dart';

void main() {
  group('HeroModel Unit Tests', () {
    final sampleMapFromApi = {
      'id': 1,
      'name': 'A-Bomb',
      'slug': '1-a-bomb',
      'powerstats': {
        'intelligence': 38,
        'strength': 100,
        'speed': 17,
        'durability': 80,
        'power': 24,
        'combat': 64,
      },
      'appearance': {
        'gender': 'Male',
        'race': 'Human',
        'height': ["6'8", "203 cm"],
        'weight': ['980 lb', '441 kg'],
      },
      'biography': {
        'fullName': 'Richard Milhouse Jones',
        'publisher': 'Marvel Comics',
        'alignment': 'good',
      },
      'work': {
        'occupation': 'Musician, adventurer',
      },
      'images': {
        'sm': 'https://example.com/a-bomb-sm.jpg',
        'lg': 'https://example.com/a-bomb-lg.jpg',
      },
    };

    test('Deve desserializar corretamente a partir do Map da API', () {
      final hero = HeroModel.fromMap(sampleMapFromApi);

      expect(hero.id, 1);
      expect(hero.name, 'A-Bomb');
      expect(hero.intelligence, 38);
      expect(hero.strength, 100);
      expect(hero.speed, 17);
      expect(hero.durability, 80);
      expect(hero.power, 24);
      expect(hero.combat, 64);
      expect(hero.gender, 'Male');
      expect(hero.race, 'Human');
      expect(hero.publisher, 'Marvel Comics');
      expect(hero.alignment, 'good');
      expect(hero.imageUrlSmall, 'https://example.com/a-bomb-sm.jpg');
    });

    test('Deve converter para Map do SQLite e reconstituir com integridade', () {
      final heroOriginal = HeroModel.fromMap(sampleMapFromApi);
      final dbMap = heroOriginal.toMap();

      final heroRestored = HeroModel.fromMap(dbMap);

      expect(heroRestored.id, heroOriginal.id);
      expect(heroRestored.name, heroOriginal.name);
      expect(heroRestored.strength, heroOriginal.strength);
      expect(heroRestored.combat, heroOriginal.combat);
      expect(heroRestored.publisher, heroOriginal.publisher);
    });

    test('getStatByName deve retornar os valores corretos independentemente de maiúsculas', () {
      final hero = HeroModel.fromMap(sampleMapFromApi);

      expect(hero.getStatByName('intelligence'), 38);
      expect(hero.getStatByName('STRENGTH'), 100);
      expect(hero.getStatByName('Speed'), 17);
      expect(hero.getStatByName('DURABILITY'), 80);
      expect(hero.getStatByName('power'), 24);
      expect(hero.getStatByName('combat'), 64);
      expect(hero.getStatByName('invalido'), 0);
    });

    test('copyWith deve atualizar apenas o powerstat evoluído após vitória em missão', () {
      final hero = HeroModel.fromMap(sampleMapFromApi);
      final upgradedHero = hero.copyWith(strength: hero.strength + 1);

      expect(upgradedHero.strength, 101);
      expect(upgradedHero.intelligence, 38); // Permanece inalterado
      expect(upgradedHero.id, hero.id);
      expect(upgradedHero.name, hero.name);
    });
  });

  group('Regras de Combate e Esquadrão', () {
    test('Simulação de combate tático por atributo sorteado', () {
      const heroA = HeroModel(
        id: 1,
        name: 'Herói Forte',
        intelligence: 40,
        strength: 95,
        speed: 50,
        durability: 80,
        power: 60,
        combat: 70,
      );

      const heroB = HeroModel(
        id: 2,
        name: 'Inimigo Ágil',
        intelligence: 70,
        strength: 60,
        speed: 90,
        durability: 60,
        power: 50,
        combat: 65,
      );

      // Rodada 1: Disputa por Força -> HeroA vence
      expect(heroA.getStatByName('strength') > heroB.getStatByName('strength'), isTrue);

      // Rodada 2: Disputa por Velocidade -> HeroB vence
      expect(heroA.getStatByName('speed') < heroB.getStatByName('speed'), isTrue);

      // Rodada 3: Disputa por Combate -> HeroA vence
      expect(heroA.getStatByName('combat') > heroB.getStatByName('combat'), isTrue);
    });
  });
}
