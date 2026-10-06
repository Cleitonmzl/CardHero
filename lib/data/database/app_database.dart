import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static const String _databaseName = 'card_hero.db';
  static const int _databaseVersion = 1;

  // Nome das tabelas
  static const String tableHeroesCache = 'heroes_cache';
  static const String tableSquad = 'squad_members';

  Database? _db;

  Future<Database> get database async {
    _db ??= await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);

    return openDatabase(
      path,
      version: _databaseVersion,
      onCreate: (db, version) async {
        // Tabela para o cache offline de todos os heróis da API
        await db.execute('''
          CREATE TABLE $tableHeroesCache (
            id INTEGER PRIMARY KEY,
            name TEXT NOT NULL,
            slug TEXT,
            intelligence INTEGER,
            strength INTEGER,
            speed INTEGER,
            durability INTEGER,
            power INTEGER,
            combat INTEGER,
            image_url_small TEXT,
            image_url_large TEXT,
            gender TEXT,
            race TEXT,
            height TEXT,
            weight TEXT,
            alignment TEXT,
            publisher TEXT,
            full_name TEXT,
            occupation TEXT
          )
        ''');

        // Tabela para os membros do esquadrão recrutado (máximo 15)
        await db.execute('''
          CREATE TABLE $tableSquad (
            id INTEGER PRIMARY KEY,
            name TEXT NOT NULL,
            slug TEXT,
            intelligence INTEGER,
            strength INTEGER,
            speed INTEGER,
            durability INTEGER,
            power INTEGER,
            combat INTEGER,
            image_url_small TEXT,
            image_url_large TEXT,
            gender TEXT,
            race TEXT,
            height TEXT,
            weight TEXT,
            alignment TEXT,
            publisher TEXT,
            full_name TEXT,
            occupation TEXT
          )
        ''');
      },
    );
  }
}
