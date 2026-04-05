import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/movie_viewmodel.dart';
import '../specific/edit_movie_view.dart';
import '../specific/movie_detail_view.dart';
import '../specific/movie_stats_view.dart';
import '../../viewmodels/auth_viewmodel.dart';

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

    try {
      await authVM.logout();
      movieVM.clearCurrentUser();

      if (!context.mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/',
        (route) => false,
      );
    } catch (e) {
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

  void _showGenreManager(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        // context.watch dentro do builder do Dialog para reagir a mudanças
        final movieVM = context.watch<MovieViewModel>();
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
                        decoration: const InputDecoration(
                          labelText: 'Novo gênero',
                        ),
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      tooltip: 'Adicionar',
                      onPressed: () {
                        context.read<MovieViewModel>().addGenre(
                          controller.text,
                        );
                        controller.clear();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Lista rolável para não estourar o dialog com muitos gêneros
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: movieVM.genres
                        .map(
                          (g) => ListTile(
                            dense: true,
                            title: Text(g),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                              tooltip: 'Remover',
                              onPressed: () =>
                                  context.read<MovieViewModel>().removeGenre(g),
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
    final movieVM = context.watch<MovieViewModel>();
    final movies = _showOnlyUnwatched
        ? movieVM.movies.where((m) => !m.watched).toList()
        : List.of(movieVM.movies);
    
    movies.sort((a, b) {
      if (a.watched == b.watched) return 0;
      return a.watched ? 1 : -1;
    });

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
          PopupMenuButton<String>( // 👈 novo menu
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
      body: movies.isEmpty
          ? const Center(child: Text('Nenhum filme encontrado.'))
          : ListView.builder(
              itemCount: movies.length,
              itemBuilder: (context, index) {
                final movie = movies[index];
                return InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MovieDetailView(movieId: movie.id),
                    ),
                  ),
                  child: Card(
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
                            IconButton(
                              icon: Icon(
                                movie.watched
                                    ? Icons.check_circle
                                    : Icons.check_circle_outline,
                                color: movie.watched
                                    ? Colors.green
                                    : Colors.grey,
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
                              onPressed: () => _confirmDelete(
                                context,
                                movie.id,
                                movie.title,
                              ),
                              tooltip: 'Remover',
                            ),
                          ],
                        ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentIndex == 0
          ? _buildMovieList(context)
          : const MovieStatsView(),
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
        ],
      ),
    );
  }
}
