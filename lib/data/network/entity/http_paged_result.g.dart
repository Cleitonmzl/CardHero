// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'http_paged_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HttpPagedResult _$HttpPagedResultFromJson(Map<String, dynamic> json) =>
    HttpPagedResult(
      first: (json['first'] as num).toInt(),
      prev: json['prev'],
      next: (json['next'] as num).toInt(),
      last: (json['last'] as num).toInt(),
      pages: (json['pages'] as num).toInt(),
      items: (json['items'] as num).toInt(),
      data: (json['data'] as List<dynamic>)
          .map((e) => MovieEntity.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$HttpPagedResultToJson(HttpPagedResult instance) =>
    <String, dynamic>{
      'first': instance.first,
      'prev': instance.prev,
      'next': instance.next,
      'last': instance.last,
      'pages': instance.pages,
      'items': instance.items,
      'data': instance.data,
    };

MovieEntity _$MovieEntityFromJson(Map<String, dynamic> json) => MovieEntity(
  title: json['title'] as String,
  year: (json['year'] as num).toInt(),
  cast: (json['cast'] as List<dynamic>).map((e) => e as String).toList(),
  genres: (json['genres'] as List<dynamic>).map((e) => e as String).toList(),
  href: json['href'] as String?,
  extract: json['extract'] as String?,
  thumbnail: json['thumbnail'] as String?,
  thumbnailWidth: (json['thumbnailWidth'] as num?)?.toInt(),
  thumbnailHeight: (json['thumbnailHeight'] as num?)?.toInt(),
);

Map<String, dynamic> _$MovieEntityToJson(MovieEntity instance) =>
    <String, dynamic>{
      'title': instance.title,
      'year': instance.year,
      'cast': instance.cast,
      'genres': instance.genres,
      'href': instance.href,
      'extract': instance.extract,
      'thumbnail': instance.thumbnail,
      'thumbnailWidth': instance.thumbnailWidth,
      'thumbnailHeight': instance.thumbnailHeight,
    };
