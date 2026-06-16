import 'dart:async';
import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../repositories/movie_repository.dart';
import '../services/omdb_service.dart';
export '../services/omdb_service.dart' show OmdbSearchItem, OmdbResult;

class MovieViewModel extends ChangeNotifier {
  final MovieRepository _repo;
  final OmdbService _omdb;

  MovieViewModel(this._repo, this._omdb);

  String? _currentUserId;
  String? get currentUserId => _currentUserId;

  List<Movie> _movies = [];
  List<Movie> get movies => List.unmodifiable(_movies);

  /// A fila ("Quero ver"), do mais recente ao mais antigo.
  List<Movie> get watchlist {
    final list =
        _movies.where((m) => m.status == MovieStatus.wantToWatch).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  /// O diário ("Já vi"), ordenado pela data em que foi assistido (mais recente
  /// primeiro).
  List<Movie> get diary {
    final list =
        _movies.where((m) => m.status == MovieStatus.watched).toList();
    list.sort((a, b) => b.diaryDate.compareTo(a.diaryDate));
    return list;
  }

  /// O destaque da entrada: o último filme do diário ou, na ausência dele, o
  /// próximo da fila.
  Movie? get highlight {
    final d = diary;
    if (d.isNotEmpty) return d.first;
    final w = watchlist;
    return w.isNotEmpty ? w.first : null;
  }

  bool _streamLoaded = false;
  bool get isStreamLoaded => _streamLoaded;

  StreamSubscription<List<Movie>>? _sub;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void setCurrentUser(String uid) {
    if (_currentUserId == uid) return;
    _currentUserId = uid;
    _streamLoaded = false;
    _sub?.cancel();
    _sub = _repo.watchMovies(uid).listen((list) {
      _streamLoaded = true;
      _movies = list;
      notifyListeners();
    });
  }

  void clearCurrentUser() {
    _currentUserId = null;
    _streamLoaded = false;
    _sub?.cancel();
    _sub = null;
    _movies = [];
    notifyListeners();
  }

  Future<void> addMovie(Movie movie) async {
    _setLoading(true);
    try {
      await _repo.addMovie(movie);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateMovie(Movie movie) async {
    _setLoading(true);
    try {
      await _repo.updateMovie(movie);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> markWatched(Movie movie) => _repo.markWatched(movie.id);

  Future<void> markWantToWatch(Movie movie) => _repo.markWantToWatch(movie.id);

  /// Alterna entre fila e diário conforme o estado atual do filme.
  Future<void> toggleWatched(Movie movie) => movie.watched
      ? _repo.markWantToWatch(movie.id)
      : _repo.markWatched(movie.id);

  Future<void> deleteMovie(String id) => _repo.deleteMovie(id);

  Future<List<OmdbSearchItem>> searchOmdbCandidates(String title) =>
      _omdb.searchCandidates(title);

  Future<OmdbResult?> fetchOmdbById(String imdbId) =>
      _omdb.fetchByImdbId(imdbId);

  bool get omdbConfigured => _omdb.isConfigured;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
