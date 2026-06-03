import 'dart:async';
import 'package:flutter/material.dart';
import '../models/genre.dart';
import '../repositories/genre_repository.dart';

class GenreViewModel extends ChangeNotifier {
  final GenreRepository _repo;

  GenreViewModel(this._repo);

  static const _defaultGenreNames = [
    'Ação',
    'Comédia',
    'Drama',
    'Terror',
    'Ficção Científica',
    'Animação',
  ];

  String? _currentUserId;
  List<Genre> _genres = [];
  StreamSubscription<List<Genre>>? _sub;
  bool _seeded = false;

  List<Genre> get genres => List.unmodifiable(_genres);
  List<String> get genreNames => _genres.map((g) => g.name).toList();

  void setCurrentUser(String uid) {
    if (_currentUserId == uid) return;
    _currentUserId = uid;
    _seeded = false;
    _sub?.cancel();
    _sub = _repo.watchGenres(uid).listen(
      (list) {
        if (list.isEmpty && !_seeded) {
          _seeded = true;
          _seedDefaultGenres(uid);
        }
        _genres = list;
        notifyListeners();
      },
      onError: (e) {
        debugPrint('GenreViewModel stream error: $e');
      },
    );
  }

  void clearCurrentUser() {
    _currentUserId = null;
    _seeded = false;
    _sub?.cancel();
    _sub = null;
    _genres = [];
    notifyListeners();
  }

  Future<void> addGenre(String name) async {
    final uid = _currentUserId;
    if (uid == null || name.trim().isEmpty) return;
    if (_genres.any((g) => g.name == name.trim())) return;

    await _repo.addGenre(Genre(
      id: '',
      userId: uid,
      name: name.trim(),
    ));
  }

  Future<void> removeGenre(String id) => _repo.deleteGenre(id);

  Future<void> updateGenre(Genre genre) => _repo.updateGenre(genre);

  Future<void> _seedDefaultGenres(String uid) async {
    for (final name in _defaultGenreNames) {
      await _repo.addGenre(Genre(id: '', userId: uid, name: name));
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
