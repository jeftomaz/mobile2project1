import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/movie_viewmodel.dart';
import '../../models/movie.dart';
import 'movie_detail_view.dart';

class MovieSearchView extends StatefulWidget {
  const MovieSearchView({super.key});

  @override
  State<MovieSearchView> createState() => _MovieSearchViewState();
}

class _MovieSearchViewState extends State<MovieSearchView> {
  final _controller = TextEditingController();
  List<Movie> _results = [];

  void _search(String query) {
    setState(() {
      _results = context.read<MovieViewModel>().searchMovies(query);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Buscar por título...',
            border: InputBorder.none,
          ),
          onChanged: _search,
        ),
        actions: [
          if (_controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _controller.clear();
                _search('');
              },
            ),
        ],
      ),
      body: _controller.text.isEmpty
          ? const Center(child: Text('Digite para buscar.'))
          : _results.isEmpty
          ? const Center(child: Text('Nenhum filme encontrado.'))
          : ListView.builder(
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final movie = _results[index];
                return ListTile(
                  leading: movie.coverBytes != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.memory(
                            movie.coverBytes!,
                            width: 40,
                            height: 56,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Icon(Icons.movie),
                  title: Text(movie.title),
                  subtitle: Text('${movie.genre} • ${movie.year}'),
                  trailing: Icon(
                    movie.watched
                        ? Icons.check_circle
                        : Icons.check_circle_outline,
                    color: movie.watched ? Colors.green : Colors.grey,
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MovieDetailView(movieId: movie.id),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
