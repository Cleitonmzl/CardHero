

import '../../domain/movie.dart';

abstract class MovieRepository {
  Future<List<Movie>> getMovies({ required int page, required int limit});
}