import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class OmdbSearchItem {
  final String imdbId;
  final String title;
  final int year;
  final String? posterUrl;

  OmdbSearchItem({
    required this.imdbId,
    required this.title,
    required this.year,
    this.posterUrl,
  });
}

class OmdbResult {
  final String title;
  final int year;
  final String genre;
  final String? posterUrl;
  final String? plot;
  final String? imdbRating;

  OmdbResult({
    required this.title,
    required this.year,
    required this.genre,
    this.posterUrl,
    this.plot,
    this.imdbRating,
  });
}

class OmdbService {
  static const _baseUrl = 'https://www.omdbapi.com/';

  String get _apiKey => dotenv.env['OMDB_API_KEY'] ?? '';

  bool get isConfigured => _apiKey.isNotEmpty;

  Future<List<OmdbSearchItem>> searchCandidates(String title) async {
    if (title.trim().isEmpty || _apiKey.isEmpty) return [];

    final uri = Uri.parse(_baseUrl).replace(queryParameters: {
      'apikey': _apiKey,
      's': title.trim(),
      'type': 'movie',
    });

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) return [];

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['Response'] == 'False') return [];

      final results = data['Search'] as List<dynamic>;
      return results.map((item) {
        final yearStr = (item['Year'] as String? ?? '0')
            .replaceAll(RegExp(r'[^0-9]'), '');
        final poster = item['Poster'] as String?;
        return OmdbSearchItem(
          imdbId: item['imdbID'] as String,
          title: item['Title'] as String,
          year: int.tryParse(yearStr) ?? 0,
          posterUrl: (poster != null && poster != 'N/A') ? poster : null,
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  Future<OmdbResult?> fetchByImdbId(String imdbId) async {
    if (_apiKey.isEmpty) return null;

    final uri = Uri.parse(_baseUrl).replace(queryParameters: {
      'apikey': _apiKey,
      'i': imdbId,
    });

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['Response'] == 'False') return null;

      final yearStr = (data['Year'] as String? ?? '0')
          .replaceAll(RegExp(r'[^0-9]'), '');
      final poster = data['Poster'] as String?;
      final genreRaw = data['Genre'] as String? ?? '';

      return OmdbResult(
        title: data['Title'] as String,
        year: int.tryParse(yearStr) ?? 0,
        genre: genreRaw.split(',').first.trim().isNotEmpty
            ? genreRaw.split(',').first.trim()
            : 'Outro',
        posterUrl: (poster != null && poster != 'N/A') ? poster : null,
        plot: data['Plot'] as String?,
        imdbRating: data['imdbRating'] as String?,
      );
    } catch (_) {
      return null;
    }
  }
}
