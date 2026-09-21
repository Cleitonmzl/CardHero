import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../entity/movie_database_entity.dart';

abstract class BaseDao {
  static const databaseVersion = 1;
  static const _databaseName = 'movie_database.db';

  Database? _database;

  @protected
  Future<Database> getDb() async {
    _database ??= await _getDatabase();
    return _database!;
  }

  Future<Database> _getDatabase() async {
    return openDatabase(
      join(await getDatabasesPath(), _databaseName),
      onCreate: (db, version) async {
        final batch = db.batch();
        _createMoviesTableV1(batch);
        await batch.commit();
      },
      version: databaseVersion,
    );
  }

  void _createMoviesTableV1(Batch batch) {
    batch.execute(
      '''
      CREATE TABLE ${MovieDatabaseContract.movieTable}(
      ${MovieDatabaseContract.idColumn} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${MovieDatabaseContract.titleColumn} TEXT NOT NULL,
      ${MovieDatabaseContract.yearColumn} INTEGER NOT NULL,
      ${MovieDatabaseContract.imgUrl} TEXT NULL,
      ${MovieDatabaseContract.extractColumn} TEXT NULL
      );
      ''',
    );
  }
}