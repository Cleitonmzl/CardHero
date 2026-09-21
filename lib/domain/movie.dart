import 'package:freezed_annotation/freezed_annotation.dart';

part 'movie.freezed.dart';

@freezed
abstract class Movie with _$Movie {
  const factory Movie({
    required String title,
    required int year,
    String? extract,
    String? imgUrl,
  }) = _Movie;
}