import 'package:flutter/material.dart';
import '../models/movie.dart';

class MovieViewModel extends ChangeNotifier {
  static const List<String> _defaultGenres = [
    'Ação',
    'Comédia',
    'Drama',
    'Terror',
    'Ficção Científica',
    'Animação',
  ];

  final Map<String, List<Movie>> _moviesByUser = {};
  final Map<String, List<String>> _genresByUser = {};
  String? _currentUserId;

  // métodos usuário
  String? get currentUserId => _currentUserId;

  void setCurrentUser(String? userId) {
    _currentUserId = userId;

    if (userId != null) {
      _moviesByUser.putIfAbsent(userId, () => []);
      _genresByUser.putIfAbsent(userId, () => List.of(_defaultGenres));
    }

    notifyListeners();
  }

  void clearCurrentUser() {
    _currentUserId = null;
    notifyListeners();
  }

  // métodos filmes
  List<Movie> get movies {
    if (_currentUserId == null) return [];
    return List.unmodifiable(_moviesByUser[_currentUserId!] ?? []);
  }
  
  void addMovie(Movie movie) {
    final userMovies = _requireCurrentUserMovies();
    userMovies.add(movie);
    notifyListeners();
  }

  void toggleWatched(String id) {
    final userMovies = _requireCurrentUserMovies();
    final movie = userMovies.firstWhere((m) => m.id == id);
    movie.watched = !movie.watched;
    notifyListeners();
  }

  void removeMovie(String id) {
    final userMovies = _requireCurrentUserMovies();
    userMovies.removeWhere((m) => m.id == id);
    notifyListeners();
  }

  void updateMovie(Movie updated) {
    final userMovies = _requireCurrentUserMovies();
    final index = userMovies.indexWhere((m) => m.id == updated.id);

    if (index != -1) {
      userMovies[index] = updated;
      notifyListeners();
    }
  }

  List<Movie> searchMovies(String query) {
    if (query.trim().isEmpty) return [];

    final q = query.toLowerCase();
    final userMovies = _currentUserId == null
        ? <Movie>[]
        : (_moviesByUser[_currentUserId!] ?? []);

    return userMovies
        .where((m) => m.title.toLowerCase().contains(q))
        .toList();
  }

  // métodos generos
  List<String> get genres {
    if (_currentUserId == null) return List.unmodifiable(_defaultGenres);
    return List.unmodifiable(_genresByUser[_currentUserId!] ?? _defaultGenres);
  }

  void addGenre(String genre) {
    final g = genre.trim();
    if (g.isEmpty) return;

    final userGenres = _requireCurrentUserGenres();
    if (userGenres.contains(g)) return;

    userGenres.add(g);
    notifyListeners();
  }

  void removeGenre(String genre) {
    final userGenres = _requireCurrentUserGenres();
    userGenres.remove(genre);
    notifyListeners();
  }

  // validações
  List<Movie> _requireCurrentUserMovies() {
    final userId = _currentUserId;
    if (userId == null) {
      throw StateError('Nenhum usuário autenticado para manipular filmes.');
    }

    return _moviesByUser.putIfAbsent(userId, () => []);
  }

  List<String> _requireCurrentUserGenres() {
    final userId = _currentUserId;
    if (userId == null) {
      throw StateError('Nenhum usuário autenticado para manipular gêneros.');
    }

    return _genresByUser.putIfAbsent(userId, () => List.of(_defaultGenres));
  }
}
