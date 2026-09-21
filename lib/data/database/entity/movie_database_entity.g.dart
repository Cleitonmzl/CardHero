// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movie_database_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MovieDatabaseEntity _$MovieDatabaseEntityFromJson(Map<String, dynamic> json) =>
    MovieDatabaseEntity(
      id: (json['id'] as num?)?.toInt(),
      title: json['title'] as String,
      year: (json['year'] as num).toInt(),
      extract: json['extract'] as String?,
      imageUrl: json['img_url'] as String?,
    );

Map<String, dynamic> _$MovieDatabaseEntityToJson(
  MovieDatabaseEntity instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'img_url': instance.imageUrl,
  'year': instance.year,
  'extract': instance.extract,
};
