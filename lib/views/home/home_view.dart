import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/genre.dart';
import '../../models/movie.dart';
import '../../viewmodels/movie_viewmodel.dart';
import '../../viewmodels/genre_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/poster_placeholder.dart';
import '../../widgets/watched_ribbon.dart';
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
    showDialog(
      context: context,
      builder: (_) => const _GenreManagerDialog(),
    );
  }

  Widget _buildMovieList(BuildContext context) {
    return Scaffold(
      body: Consumer<MovieViewModel>(
        builder: (context, movieVM, _) {
          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(context),
              _buildSliverBody(context, movieVM),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/movie/add'),
        child: const Icon(Icons.add),
      ),
    );
  }

  /// SliverAppBar colapsável: exibe o logo Framy quando expandido e colapsa
  /// para apenas o título e as ações ao rolar a lista.
  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 140,
      automaticallyImplyLeading: false,
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final topPadding = MediaQuery.of(context).padding.top;
          final collapsed =
              constraints.biggest.height <= kToolbarHeight + topPadding + 12;
          return FlexibleSpaceBar(
            centerTitle: true,
            titlePadding: const EdgeInsets.only(bottom: 14),
            // Logo quando expandido, título apenas quando colapsado.
            title: AnimatedOpacity(
              opacity: collapsed ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: const Text('Meus Filmes'),
            ),
            background: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Image.asset(
                'assets/images/framy_logo.png',
                fit: BoxFit.contain,
              ),
            ),
          );
        },
      ),
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
    );
  }

  Widget _buildSliverBody(BuildContext context, MovieViewModel movieVM) {
    if (!movieVM.isStreamLoaded) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    var movies = List<Movie>.from(movieVM.movies);
    if (_showOnlyUnwatched) {
      movies = movies.where((m) => !m.watched).toList();
    }
    movies.sort((a, b) {
      if (a.watched == b.watched) return 0;
      return a.watched ? 1 : -1;
    });

    if (movies.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: Text('Nenhum filme encontrado.')),
      );
    }

    return SliverList.builder(
      itemCount: movies.length,
      itemBuilder: (context, index) =>
          _MovieCard(movie: movies[index], onDelete: _confirmDelete),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildMovieList(context),
          const MovieStatsView(),
          const AccountView(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) =>
            setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.movie_outlined),
            selectedIcon: Icon(Icons.movie),
            label: 'Filmes',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Estatísticas',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Minha Conta',
          ),
        ],
      ),
    );
  }
}

/// Card de filme no estilo pôster (Letterboxd): pôster em tamanho real à
/// esquerda, gradiente escuro sobre a área de texto, ribbon "Assistido" e
/// transição Hero ao abrir o detalhe.
class _MovieCard extends StatelessWidget {
  final Movie movie;
  final void Function(BuildContext, String id, String title) onDelete;

  const _MovieCard({required this.movie, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final movieVM = context.read<MovieViewModel>();

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MovieDetailView(movie: movie)),
        ),
        child: SizedBox(
          height: 130,
          child: Stack(
            children: [
              Row(
                children: [
                  Hero(
                    tag: 'poster-${movie.id}',
                    child: movie.posterUrl != null
                        ? Image.network(
                            movie.posterUrl!,
                            width: 88,
                            height: 130,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stack) =>
                                const PosterPlaceholder(width: 88, height: 130),
                          )
                        : const PosterPlaceholder(width: 88, height: 130),
                  ),
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [Color(0xFF0D0D0D), Color(0xFF1A1A1A)],
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(14, 12, 4, 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  movie.title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(fontSize: 22, height: 1.0),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
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
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                icon: Icon(
                                  movie.watched
                                      ? Icons.check_circle
                                      : Icons.check_circle_outline,
                                  color:
                                      movie.watched ? Colors.green : Colors.grey,
                                ),
                                onPressed: () => movieVM.toggleWatched(
                                    movie.id, movie.watched),
                                tooltip: movie.watched
                                    ? 'Marcar como não assistido'
                                    : 'Marcar como assistido',
                              ),
                              IconButton(
                                visualDensity: VisualDensity.compact,
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
                                visualDensity: VisualDensity.compact,
                                icon: const Icon(Icons.delete_outline,
                                    color: Colors.red),
                                onPressed: () =>
                                    onDelete(context, movie.id, movie.title),
                                tooltip: 'Remover',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (movie.watched) const WatchedRibbon(),
            ],
          ),
        ),
      ),
    );
  }
}

class _GenreManagerDialog extends StatefulWidget {
  const _GenreManagerDialog();

  @override
  State<_GenreManagerDialog> createState() => _GenreManagerDialogState();
}

class _GenreManagerDialogState extends State<_GenreManagerDialog> {
  final _addController = TextEditingController();

  @override
  void dispose() {
    _addController.dispose();
    super.dispose();
  }

  void _showRenameDialog(Genre genre) {
    final renameController = TextEditingController(text: genre.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Renomear Gênero'),
        content: TextField(
          controller: renameController,
          decoration: const InputDecoration(labelText: 'Nome'),
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final name = renameController.text.trim();
              if (name.isEmpty) return;
              await context.read<GenreViewModel>().updateGenre(
                    Genre(id: genre.id, userId: genre.userId, name: name),
                  );
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    controller: _addController,
                    decoration: const InputDecoration(labelText: 'Novo gênero'),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: 'Adicionar',
                  onPressed: () async {
                    await context.read<GenreViewModel>().addGenre(_addController.text);
                    _addController.clear();
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (genreVM.genres.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Nenhum gênero cadastrado.',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: genreVM.genres
                      .map((g) => ListTile(
                            dense: true,
                            title: Text(g.name),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined),
                                  tooltip: 'Renomear',
                                  onPressed: () => _showRenameDialog(g),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                  ),
                                  tooltip: 'Remover',
                                  onPressed: () =>
                                      context.read<GenreViewModel>().removeGenre(g.id),
                                ),
                              ],
                            ),
                          ))
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
  }
}
