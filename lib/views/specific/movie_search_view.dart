import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/movie.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../repositories/movie_repository.dart';
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
    final uid = context.read<AuthViewModel>().currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Buscar por título...',
            border: InputBorder.none,
          ),
          onChanged: (value) => setState(() {}),
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
      body: _controller.text.isEmpty
          ? const Center(child: Text('Digite para buscar.'))
          : StreamBuilder<List<Movie>>(
              stream: context
                  .read<MovieRepository>()
                  .searchMovies(uid, _controller.text),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final results = snapshot.data ?? [];
                if (results.isEmpty) {
                  return const Center(child: Text('Nenhum filme encontrado.'));
                }
                return ListView.builder(
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
                                errorBuilder: (context, error, stack) =>
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
                        color: movie.watched ? Colors.green : Colors.grey,
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MovieDetailView(movie: movie),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
