import 'package:json_annotation/json_annotation.dart';

part 'movie_database_entity.g.dart';

@JsonSerializable()
class MovieDatabaseEntity {

  @JsonKey(name: MovieDatabaseContract.idColumn)
  final int? id;
  @JsonKey(name: MovieDatabaseContract.titleColumn)
  final String title;
  @JsonKey(name: MovieDatabaseContract.imgUrl)
  final String? imageUrl;
  @JsonKey(name: MovieDatabaseContract.yearColumn)
  final int year;
  @JsonKey(name: MovieDatabaseContract.extractColumn)
  final String? extract;

  MovieDatabaseEntity({
    required this.id,
    required this.title,
    required this.year,
    this.extract,
    this.imageUrl,
  });

  factory MovieDatabaseEntity.fromJson(Map<String, dynamic> json) =>
      _$MovieDatabaseEntityFromJson(json);

  Map<String, dynamic> toJson() => _$MovieDatabaseEntityToJson(this);
}

abstract class MovieDatabaseContract {
  static const String movieTable = "movie_table";
  static const String idColumn = "id";
  static const String titleColumn = "title";
  static const String yearColumn = "year";
  static const String extractColumn = "extract";
  static const String imgUrl = "img_url";
}
