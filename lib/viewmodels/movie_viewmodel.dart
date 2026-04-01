import 'package:flutter/material.dart';
import '../models/movie.dart';

class MovieViewModel extends ChangeNotifier {
  final List<Movie> _movies = [];

  List<Movie> get movies => List.unmodifiable(_movies);

  void addMovie(Movie movie) {
    _movies.add(movie);
    notifyListeners();
  }

  void toggleWatched(String id) {
    final movie = _movies.firstWhere((m) => m.id == id);
    movie.watched = !movie.watched;
    notifyListeners();
  }

  void removeMovie(String id) {
    _movies.removeWhere((m) => m.id == id);
    notifyListeners();
  }

  void updateMovie(Movie updated) {
    final index = _movies.indexWhere((m) => m.id == updated.id);
    if (index != -1) {
      _movies[index] = updated;
      notifyListeners();
    }
  }

  List<Movie> searchMovies(String query) {
    if (query.trim().isEmpty) return [];
    final q = query.toLowerCase();
    return _movies.where((m) => m.title.toLowerCase().contains(q)).toList();
  }
}
