


import '../../domain/exception/mapper_exception.dart';
import '../../domain/movie.dart';
import 'entity/movie_database_entity.dart';

class DatabaseMapper{

  Movie toMovie(MovieDatabaseEntity entity){
    try{
      return Movie(
          title: entity.title,
          year: entity.year,
          extract: entity.extract,
          imgUrl: entity.imageUrl
      );
    }catch (e){
      throw MapperException<MovieDatabaseEntity, Movie>(e.toString());
    }
  }

  List<Movie> toMovies(List<MovieDatabaseEntity> entities){
    final List<Movie> movies = [];
    for (var movieEntity in entities) {
      movies.add(toMovie(movieEntity));
    }
    return movies;
  }

  MovieDatabaseEntity toMovieDatabaseEntity(Movie movie){
    try{
      return MovieDatabaseEntity(
          id: null,
          title: movie.title,
          year: movie.year,
          extract: movie.extract,
          imageUrl: movie.imgUrl
      );
    }catch (e){
      throw MapperException<MovieDatabaseEntity, Movie>(e.toString());
    }
  }

  List<MovieDatabaseEntity> toMovieDatabaseEntities(List<Movie> movies){
    final List<MovieDatabaseEntity> movieDatabaseEntities = [];
    for (var m in movies) {
      movieDatabaseEntities.add(toMovieDatabaseEntity(m));
    }
    return movieDatabaseEntities;
  }
}