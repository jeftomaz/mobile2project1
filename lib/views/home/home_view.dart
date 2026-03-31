import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/movie_viewmodel.dart';
import '../specific/edit_movie_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  void _confirmDelete(BuildContext context, String id, String title) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remover filme'),
        content: Text('Deseja remover "$title"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.read<MovieViewModel>().removeMovie(id);
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Filme removido.')));
            },
            child: const Text('Remover', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final movieVM = context.watch<MovieViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Filmes'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => Navigator.pushNamed(context, '/about'),
          ),
        ],
      ),
      body: movieVM.movies.isEmpty
          ? const Center(child: Text('Nenhum filme adicionado ainda.'))
          : ListView.builder(
              itemCount: movieVM.movies.length,
              itemBuilder: (context, index) {
                final movie = movieVM.movies[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: Opacity(
                    opacity: movie.watched ? 0.4 : 1.0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          // Capa
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: movie.coverBytes != null
                                ? Image.memory(
                                    movie.coverBytes!,
                                    width: 50,
                                    height: 70,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    width: 50,
                                    height: 70,
                                    color: Colors.grey[200],
                                    child: const Icon(
                                      Icons.movie,
                                      color: Colors.grey,
                                    ),
                                  ),
                          ),
                          const SizedBox(width: 12),
                          // Título e info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  movie.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${movie.genre} • ${movie.year}',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Botões
                          IconButton(
                            icon: Icon(
                              movie.watched
                                  ? Icons.check_circle
                                  : Icons.check_circle_outline,
                              color: movie.watched ? Colors.green : Colors.grey,
                            ),
                            onPressed: () => movieVM.toggleWatched(movie.id),
                            tooltip: movie.watched
                                ? 'Marcar como não assistido'
                                : 'Marcar como assistido',
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditMovieView(movie: movie),
                              ),
                            ),
                            tooltip: 'Editar',
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            onPressed: () =>
                                _confirmDelete(context, movie.id, movie.title),
                            tooltip: 'Remover',
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/movie/add'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
