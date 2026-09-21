import 'package:json_annotation/json_annotation.dart';

part 'http_paged_result.g.dart';

@JsonSerializable()
class HttpPagedResult {
  int first;
  dynamic prev;
  int next;
  int last;
  int pages;
  int items;
  List<MovieEntity> data;

  HttpPagedResult({
    required this.first,
    required this.prev,
    required this.next,
    required this.last,
    required this.pages,
    required this.items,
    required this.data,
  });

  factory HttpPagedResult.fromJson(Map<String, dynamic> json) => _$HttpPagedResultFromJson(json);
}

@JsonSerializable()
class MovieEntity {
  String title;
  int year;
  List<String> cast;
  List<String> genres;
  String? href;
  String? extract;
  String? thumbnail;
  int? thumbnailWidth;
  int? thumbnailHeight;

  MovieEntity({
    required this.title,
    required this.year,
    required this.cast,
    required this.genres,
    this.href,
    this.extract,
    this.thumbnail,
    this.thumbnailWidth,
    this.thumbnailHeight,
  });

  factory MovieEntity.fromJson(Map<String, dynamic> json) => _$MovieEntityFromJson(json);

  @override
  String toString() {
    return 'MovieEntity{title: $title, year: $year}';
  }
}