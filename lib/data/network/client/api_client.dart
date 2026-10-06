import 'package:dio/dio.dart';
import '../../../domain/hero_model.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient({required String baseUrl}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 4),
        receiveTimeout: const Duration(seconds: 4),
      ),
    )..interceptors.add(
        LogInterceptor(
          requestBody: false,
          responseBody: false,
        ),
      );
  }

  /// Busca a lista paginada de heróis
  Future<List<HeroModel>> getHeroes({required int page, required int limit}) async {
    try {
      final response = await _dio.get(
        "/heroes",
        queryParameters: {
          '_page': page,
          '_limit': limit,
          '_per_page': limit, // Suporta tanto json-server v0.17 quanto v1.0
        },
      );

      if (response.statusCode == 200) {
        dynamic rawData = response.data;
        List<dynamic> list;

        if (rawData is List) {
          list = rawData;
        } else if (rawData is Map<String, dynamic> && rawData['data'] is List) {
          list = rawData['data'] as List;
        } else {
          list = [];
        }

        return list.map((item) => HeroModel.fromMap(item as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Erro na requisição: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Busca um herói específico por ID na API
  Future<HeroModel?> getHeroById(int id) async {
    try {
      final response = await _dio.get("/heroes/$id");
      if (response.statusCode == 200 && response.data != null) {
        return HeroModel.fromMap(response.data as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
