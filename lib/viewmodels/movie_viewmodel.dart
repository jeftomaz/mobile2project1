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

  Future<void> toggleWatched(String id, bool currentValue) =>
      _repo.toggleWatched(id, currentValue);

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
