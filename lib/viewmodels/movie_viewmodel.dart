import 'dart:async';
import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../repositories/movie_repository.dart';
import '../services/omdb_service.dart';

class MovieViewModel extends ChangeNotifier {
  final MovieRepository _repo;
  final OmdbService _omdb;

  MovieViewModel(this._repo, this._omdb);

  String? _currentUserId;
  String? get currentUserId => _currentUserId;

  List<Movie> _movies = [];
  List<Movie> get movies => List.unmodifiable(_movies);

  Stream<List<Movie>>? _moviesStream;
  Stream<List<Movie>>? get moviesStream => _moviesStream;

  StreamSubscription<List<Movie>>? _sub;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void setCurrentUser(String uid) {
    if (_currentUserId == uid) return;
    _currentUserId = uid;
    _sub?.cancel();
    _moviesStream = _repo.watchMovies(uid);
    _sub = _moviesStream!.listen((list) {
      _movies = list;
      notifyListeners();
    });
  }

  void clearCurrentUser() {
    _currentUserId = null;
    _sub?.cancel();
    _sub = null;
    _moviesStream = null;
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

  Future<void> toggleWatched(String id, bool currentValue) =>
      _repo.toggleWatched(id, currentValue);

  Future<void> deleteMovie(String id) => _repo.deleteMovie(id);

  Future<OmdbResult?> searchOmdb(String title) =>
      _omdb.searchByTitle(title);

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
