import 'dart:convert';
import 'package:http/http.dart' as http;

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
  // Obtenha sua chave gratuita em: https://www.omdbapi.com/apikey.aspx
  static const _apiKey = '';
  static const _baseUrl = 'https://www.omdbapi.com/';

  bool get isConfigured => _apiKey.isNotEmpty;

  Future<OmdbResult?> searchByTitle(String title) async {
    if (title.trim().isEmpty || _apiKey.isEmpty) return null;

    final uri = Uri.parse(_baseUrl).replace(queryParameters: {
      'apikey': _apiKey,
      't': title.trim(),
      'type': 'movie',
    });

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['Response'] == 'False') return null;

      final yearStr = (data['Year'] as String? ?? '0')
          .replaceAll(RegExp(r'[^0-9]'), '');
      final year = int.tryParse(yearStr) ?? 0;

      final poster = data['Poster'] as String?;
      final genreRaw = data['Genre'] as String? ?? '';

      return OmdbResult(
        title: data['Title'] as String,
        year: year,
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
