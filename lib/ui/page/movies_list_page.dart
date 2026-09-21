import 'package:flutter/material.dart';
import 'package:flutter_repository_example/domain/movie.dart';
import 'package:flutter_repository_example/ui/widgets/movie_card.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';

import '../../data/repository/movie_repository_impl.dart';

class MoviesListPage extends StatefulWidget {
  const MoviesListPage({super.key});

  @override
  State<MoviesListPage> createState() => _MoviesListPageState();
}

class _MoviesListPageState extends State<MoviesListPage> {

  late final MovieRepositoryImpl moviesRepo;
  late final PagingController<int, Movie> _pagingController = PagingController<int, Movie>(
    getNextPageKey: (state) => state.lastPageIsEmpty ? null : state.nextIntPageKey,
    fetchPage: (pageKey) => moviesRepo.getMovies(page: pageKey, limit: 10)
  );


  @override
  void initState() {
    super.initState();
    moviesRepo = Provider.of<MovieRepositoryImpl>(context, listen: false);
  }

  @override
  void dispose() {
    super.dispose();
    _pagingController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Movies"),
          backgroundColor: Theme.of(context).primaryColorLight,
        ),
        body: PagingListener(
          controller: _pagingController,
          builder: (context, state, fetchNextPage) => PagedListView<int, Movie>(
            state: state,
            fetchNextPage: fetchNextPage,
            builderDelegate: PagedChildBuilderDelegate(
              itemBuilder: (context, movie, index) => MovieCard(movie: movie),
            ),
          ),
        )

        /*
      body: FutureBuilder(
          future: moviesRepo.getMovies(page: 1, limit: 10),
          builder: (context, snapshop) {
            if (snapshop.hasData) {
              return ListView(
                children: List.generate(
                  snapshop.data!.length,
                  (index) => MovieCard(movie: snapshop.data![index]),
                ),
              );
            } else {
              return LinearProgressIndicator();
            }
          }),*/
        );

    /*
    return Scaffold(
      appBar: AppBar(
        title: Text("Movies"),
      ),
      body: FutureBuilder(
          future: moviesRepo.getMovies(),
          builder: (context, snapshop) {
            if (snapshop.hasData) {
              return ListView(
                children: List.generate(
                    snapshop.data!.length,
                    (index) => ListTile(
                          title: Text(snapshop.data![index].title),
                        )),
              );
            } else {
              return LinearProgressIndicator();
            }
          }),
    );
     */
  }
}
