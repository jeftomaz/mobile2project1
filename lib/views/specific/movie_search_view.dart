import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/movie.dart';
import '../../viewmodels/movie_viewmodel.dart';
import 'movie_detail_view.dart';

/// Critérios de ordenação dos resultados da busca (RF006).
enum SearchSort { relevance, titleAsc, yearDesc, recent }

extension on SearchSort {
  String get label => switch (this) {
    SearchSort.relevance => 'Relevância',
    SearchSort.titleAsc => 'Título (A–Z)',
    SearchSort.yearDesc => 'Ano (mais novo)',
    SearchSort.recent => 'Adicionados recentemente',
  };
}

class MovieSearchView extends StatefulWidget {
  const MovieSearchView({super.key});

  @override
  State<MovieSearchView> createState() => _MovieSearchViewState();
}

class _MovieSearchViewState extends State<MovieSearchView> {
  final _controller = TextEditingController();
  SearchSort _sort = SearchSort.relevance;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Aplica o critério de ordenação escolhido. "Relevância" prioriza títulos
  /// que começam com o termo, depois mantém a ordem original (mais recentes).
  List<Movie> _sortResults(List<Movie> results, String query) {
    final list = List<Movie>.from(results);
    switch (_sort) {
      case SearchSort.relevance:
        list.sort((a, b) {
          final aStarts = a.title.toLowerCase().startsWith(query) ? 0 : 1;
          final bStarts = b.title.toLowerCase().startsWith(query) ? 0 : 1;
          if (aStarts != bStarts) return aStarts - bStarts;
          return b.createdAt.compareTo(a.createdAt);
        });
      case SearchSort.titleAsc:
        list.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
      case SearchSort.yearDesc:
        list.sort((a, b) => b.year.compareTo(a.year));
      case SearchSort.recent:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final allMovies = context.watch<MovieViewModel>().movies;
    final query = _controller.text.toLowerCase().trim();

    // Busca case-insensitive por título (RF006).
    final results = query.isEmpty
        ? <Movie>[]
        : _sortResults(
            allMovies
                .where((m) => m.title.toLowerCase().contains(query))
                .toList(),
            query,
          );

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Buscar por título...',
            border: InputBorder.none,
          ),
          onChanged: (_) => setState(() {}),
        ),
        actions: [
          if (_controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _controller.clear();
                setState(() {});
              },
            ),
          PopupMenuButton<SearchSort>(
            icon: const Icon(Icons.sort),
            tooltip: 'Ordenar',
            initialValue: _sort,
            onSelected: (value) => setState(() => _sort = value),
            itemBuilder: (context) => SearchSort.values
                .map((s) => PopupMenuItem(value: s, child: Text(s.label)))
                .toList(),
          ),
        ],
      ),
      body: query.isEmpty
          ? const Center(child: Text('Digite para buscar.'))
          : results.isEmpty
          ? const Center(child: Text('Nenhum filme encontrado.'))
          : Column(
              children: [
                // Barra de contexto: total + critério de ordenação ativo.
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Row(
                    children: [
                      Text(
                        '${results.length} resultado${results.length != 1 ? 's' : ''}',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 13,
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.sort, size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(
                        _sort.label,
                        style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final movie = results[index];
                      return ListTile(
                        leading: movie.posterUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Image.network(
                                  movie.posterUrl!,
                                  width: 40,
                                  height: 56,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) =>
                                      const Icon(Icons.movie),
                                ),
                              )
                            : const Icon(Icons.movie),
                        title: Text(movie.title),
                        subtitle: Text('${movie.genre} • ${movie.year}'),
                        trailing: Icon(
                          movie.watched
                              ? Icons.check_circle
                              : Icons.bookmark_outline,
                          color: movie.watched
                              ? Colors.green
                              : Colors.grey,
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MovieDetailView(movie: movie),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
