

import '../../domain/exception/mapper_exception.dart';
import '../../domain/movie.dart';
import 'entity/http_paged_result.dart';

class NetworkMapper{

  Movie toMovie(MovieEntity entity){
    try{
      return Movie(
        title: entity.title,
        year: entity.year,
        extract: entity.extract,
        imgUrl: entity.thumbnail
      );
    }catch (e){
      throw MapperException<MovieEntity, Movie>(e.toString());
    }
  }

  List<Movie> toMovies(List<MovieEntity> entities){
    final List<Movie> movies = [];
    for (var movieEntity in entities) {
      movies.add(toMovie(movieEntity));
    }
    return movies;
  }
}