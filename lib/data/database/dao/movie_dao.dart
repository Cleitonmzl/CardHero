
import 'package:sqflite/sqflite.dart';

import '../entity/movie_database_entity.dart';
import 'base_dao.dart';

class MovieDao extends BaseDao {


  Future<List<MovieDatabaseEntity>> selectAll({
    int? limit,
    int? offset,
  }) async {
    final Database db = await getDb();
    final List<Map<String, dynamic>> maps = await db.query(
      MovieDatabaseContract.movieTable,
      limit: limit,
      offset: offset,
      orderBy: '${MovieDatabaseContract.idColumn} ASC',
    );
    return List.generate(maps.length, (i) {
      return MovieDatabaseEntity.fromJson(maps[i]);
    });
  }

  Future<void> insert(MovieDatabaseEntity entity) async {
    final Database db = await getDb();
    await db.insert(MovieDatabaseContract.movieTable, entity.toJson());
  }

  Future<void> insertAll(List<MovieDatabaseEntity> entities) async {
    final Database db = await getDb();
    await db.transaction((transaction) async {
      for (final entity in entities) {
        transaction.insert(MovieDatabaseContract.movieTable, entity.toJson());
      }
    });
  }

  Future<void> deleteAll() async {
    final Database db = await getDb();
    await db.delete(MovieDatabaseContract.movieTable);
  }
}
