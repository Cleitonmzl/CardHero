import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../domain/movie.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;

  const MovieCard({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Row(
        children: [
          if (movie.imgUrl != null)
            Container(
              alignment: Alignment.center,
              child: SizedBox(
                width: 100,
                height: 150,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(imageUrl: movie.imgUrl!),
                ),
              ),
            )
          else
            const Icon(
              Icons.image_not_supported,
              size: 100,
              color: Colors.black,
            ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.only(
                left: 8,
                top: 8,
                right: 8,
                bottom: 8,
              ),
              child: Column(
                children: [
                  Text(
                    "${movie.title} (${movie.year})",
                    style: Theme.of(context).textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (movie.extract != null)
                    Text(
                      movie.extract!,
                      textAlign: TextAlign.justify,
                    )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
