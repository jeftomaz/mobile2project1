import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/movie.dart';
import '../../viewmodels/movie_viewmodel.dart';
import '../../widgets/movie_poster.dart';
import '../specific/movie_detail_view.dart';
import 'home_actions.dart';

/// **Agora** — a abertura do app. Em vez de logo + lista, uma capa de revista
/// em tela cheia (último assistido ou destaque da fila) e, abaixo, o carrossel
/// "Próximo da fila".
class NowView extends StatelessWidget {
  const NowView({super.key});

  void _openDetail(BuildContext context, Movie movie) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MovieDetailView(movie: movie)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final movieVM = context.watch<MovieViewModel>();

    if (!movieVM.isStreamLoaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final highlight = movieVM.highlight;
    final queue = movieVM.watchlist;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/movie/add'),
        icon: const Icon(Icons.add),
        label: const Text('Novo filme'),
      ),
      body: highlight == null
          ? _EmptyNow()
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _CoverHeader(
                    movie: highlight,
                    onTap: () => _openDetail(context, highlight),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _QueueSection(
                    queue: queue,
                    onTapMovie: (m) => _openDetail(context, m),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 96)),
              ],
            ),
    );
  }
}

/// Capa full-bleed do destaque: pôster em tela quase cheia, gradiente escuro,
/// título em Bebas e uma frase que muda conforme o filme esteja no diário ou
/// na fila.
class _CoverHeader extends StatelessWidget {
  final Movie movie;
  final VoidCallback onTap;

  const _CoverHeader({required this.movie, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.62;
    final topPadding = MediaQuery.of(context).padding.top;
    final phrase = movie.watched
        ? 'O último capítulo do seu diário'
        : 'O próximo da sua fila';

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            MoviePoster(
              movie: movie,
              width: double.infinity,
              height: height,
              radius: 0,
            ),
            // Gradiente para legibilidade do texto sobreposto.
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black54,
                    Colors.transparent,
                    Colors.transparent,
                    Color(0xFF0D0D0D),
                  ],
                  stops: [0.0, 0.25, 0.55, 1.0],
                ),
              ),
            ),
            // Ações do topo (busca + menu), sobrepostas à capa.
            Positioned(
              top: topPadding + 4,
              right: 4,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.search, color: Colors.white),
                    tooltip: 'Buscar',
                    onPressed: () =>
                        Navigator.pushNamed(context, '/movie/search'),
                  ),
                  const AppOverflowMenu(),
                ],
              ),
            ),
            // Selo do topo.
            Positioned(
              top: topPadding + 12,
              left: 20,
              child: Row(
                children: [
                  Icon(
                    movie.watched ? Icons.auto_stories : Icons.bookmark,
                    size: 16,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    movie.watched ? 'NO SEU DIÁRIO' : 'NA SUA FILA',
                    style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    phrase,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 13,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    movie.title,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      height: 0.95,
                      shadows: const [
                        Shadow(blurRadius: 12, color: Colors.black),
                      ],
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${movie.genre} • ${movie.year}',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Carrossel horizontal "Próximo da fila".
class _QueueSection extends StatelessWidget {
  final List<Movie> queue;
  final void Function(Movie) onTapMovie;

  const _QueueSection({required this.queue, required this.onTapMovie});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Row(
            children: [
              Text(
                'Próximo da fila',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(width: 8),
              if (queue.isNotEmpty)
                Text(
                  '${queue.length}',
                  style: const TextStyle(color: Colors.white38, fontSize: 14),
                ),
            ],
          ),
        ),
        if (queue.isEmpty)
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text(
              'Sua fila está vazia. Adicione filmes que você quer ver.',
              style: TextStyle(color: Colors.grey),
            ),
          )
        else
          SizedBox(
            height: 210,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: queue.length,
              separatorBuilder: (_, _) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final movie = queue[index];
                return GestureDetector(
                  onTap: () => onTapMovie(movie),
                  child: SizedBox(
                    width: 120,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MoviePoster(
                          movie: movie,
                          width: 120,
                          height: 168,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          movie.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

/// Estado vazio do app inteiro: nenhum filme cadastrado ainda.
class _EmptyNow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          const Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: EdgeInsets.all(4),
              child: AppOverflowMenu(),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.local_movies_outlined,
                    size: 72,
                    color: Colors.white24,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Sua vida no cinema começa aqui',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Adicione o primeiro filme à sua fila ou ao seu diário.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
