import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/movie.dart';
import '../../viewmodels/movie_viewmodel.dart';
import '../../viewmodels/genre_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../specific/edit_movie_view.dart';
import '../specific/movie_detail_view.dart';
import '../specific/movie_stats_view.dart';
import '../specific/account_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _currentIndex = 0;
  bool _showOnlyUnwatched = false;

  void _handleLogout(BuildContext context) async {
    final authVM = context.read<AuthViewModel>();
    final movieVM = context.read<MovieViewModel>();
    final genreVM = context.read<GenreViewModel>();

    try {
      await authVM.logout();
      movieVM.clearCurrentUser();
      genreVM.clearCurrentUser();

      if (!context.mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao sair da conta.')),
      );
    }
  }

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
            onPressed: () async {
              Navigator.pop(context);
              try {
                await context.read<MovieViewModel>().deleteMovie(id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Filme removido.')),
                  );
                }
              } catch (_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Erro ao remover filme.')),
                  );
                }
              }
            },
            child: const Text('Remover', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showGenreManager(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        final genreVM = context.watch<GenreViewModel>();
        return AlertDialog(
          title: const Text('Gerenciar Gêneros'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        decoration: const InputDecoration(labelText: 'Novo gênero'),
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      tooltip: 'Adicionar',
                      onPressed: () async {
                        await context.read<GenreViewModel>().addGenre(controller.text);
                        controller.clear();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: genreVM.genres
                        .map(
                          (g) => ListTile(
                            dense: true,
                            title: Text(g.name),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              tooltip: 'Remover',
                              onPressed: () =>
                                  context.read<GenreViewModel>().removeGenre(g.id),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMovieList(BuildContext context) {
    final movieVM = context.read<MovieViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Filmes'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(
              _showOnlyUnwatched ? Icons.filter_alt : Icons.filter_alt_outlined,
            ),
            tooltip: 'Apenas não assistidos',
            onPressed: () =>
                setState(() => _showOnlyUnwatched = !_showOnlyUnwatched),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.pushNamed(context, '/movie/search'),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'genres':
                  _showGenreManager(context);
                  break;
                case 'about':
                  Navigator.pushNamed(context, '/about');
                  break;
                case 'logout':
                  _handleLogout(context);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'genres',
                child: ListTile(
                  leading: Icon(Icons.category_outlined),
                  title: Text('Gerenciar Gêneros'),
                ),
              ),
              const PopupMenuItem(
                value: 'about',
                child: ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('Sobre'),
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Sair'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: StreamBuilder<List<Movie>>(
        stream: movieVM.moviesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Erro ao carregar filmes: ${snapshot.error}'),
            );
          }

          var movies = snapshot.data ?? [];
          if (_showOnlyUnwatched) {
            movies = movies.where((m) => !m.watched).toList();
          }
          movies.sort((a, b) {
            if (a.watched == b.watched) return 0;
            return a.watched ? 1 : -1;
          });

          if (movies.isEmpty) {
            return const Center(child: Text('Nenhum filme encontrado.'));
          }

          return ListView.builder(
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MovieDetailView(movie: movie),
                  ),
                ),
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Opacity(
                    opacity: movie.watched ? 0.4 : 1.0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: movie.posterUrl != null
                                ? Image.network(
                                    movie.posterUrl!,
                                    width: 50,
                                    height: 70,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stack) => _posterPlaceholder(),
                                  )
                                : _posterPlaceholder(),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  movie.title,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
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
                          IconButton(
                            icon: Icon(
                              movie.watched
                                  ? Icons.check_circle
                                  : Icons.check_circle_outline,
                              color: movie.watched ? Colors.green : Colors.grey,
                            ),
                            onPressed: () =>
                                movieVM.toggleWatched(movie.id, movie.watched),
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
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/movie/add'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _posterPlaceholder() => Container(
    width: 50,
    height: 70,
    color: Colors.grey[800],
    child: const Icon(Icons.movie, color: Colors.grey),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: [
        _buildMovieList(context),
        const MovieStatsView(),
        const AccountView(),
      ][_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.movie_outlined),
            activeIcon: Icon(Icons.movie),
            label: 'Filmes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: 'Estatísticas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Minha Conta',
          ),
        ],
      ),
    );
  }
}
