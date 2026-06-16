import 'package:flutter/material.dart';
import '../models/movie.dart';
import 'poster_placeholder.dart';

/// Pôster de um filme com cantos arredondados, transição Hero compartilhada
/// (`poster-<id>`) e placeholder shimmer enquanto carrega ou quando ausente.
class MoviePoster extends StatelessWidget {
  final Movie movie;
  final double width;
  final double height;
  final double radius;
  final bool hero;

  const MoviePoster({
    super.key,
    required this.movie,
    required this.width,
    required this.height,
    this.radius = 8,
    this.hero = true,
  });

  @override
  Widget build(BuildContext context) {
    final poster = movie.posterUrl;
    Widget image = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: poster != null
          ? Image.network(
              poster,
              width: width,
              height: height,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) =>
                  PosterPlaceholder(width: width, height: height, radius: radius),
            )
          : PosterPlaceholder(width: width, height: height, radius: radius),
    );

    if (hero) {
      image = Hero(tag: 'poster-${movie.id}', child: image);
    }
    return image;
  }
}
