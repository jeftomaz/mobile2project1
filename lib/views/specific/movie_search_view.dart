import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/movie.dart';
import '../../viewmodels/movie_viewmodel.dart';
import 'movie_detail_view.dart';

class MovieSearchView extends StatefulWidget {
  const MovieSearchView({super.key});

  @override
  State<MovieSearchView> createState() => _MovieSearchViewState();
}

class _MovieSearchViewState extends State<MovieSearchView> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allMovies = context.watch<MovieViewModel>().movies;
    final query = _controller.text.toLowerCase().trim();

    final List<Movie> results = query.isEmpty
        ? []
        : allMovies
            .where((m) => m.title.toLowerCase().contains(query))
            .toList();

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
        ],
      ),
      body: query.isEmpty
          ? const Center(child: Text('Digite para buscar.'))
          : results.isEmpty
              ? const Center(child: Text('Nenhum filme encontrado.'))
              : ListView.builder(
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
                            : Icons.check_circle_outline,
                        color:
                            movie.watched ? Colors.green : Colors.grey,
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
    );
  }
}
