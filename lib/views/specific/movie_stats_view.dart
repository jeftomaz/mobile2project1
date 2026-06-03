import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/genre_viewmodel.dart';
import '../../viewmodels/movie_viewmodel.dart';

class MovieStatsView extends StatelessWidget {
  final bool embedded;
  const MovieStatsView({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final movies = context.watch<MovieViewModel>().movies;

    final total = movies.length;
    final watched = movies.where((m) => m.watched).length;
    final unwatched = total - watched;
    final watchPercent = total > 0 ? watched / total : 0.0;

    final Map<String, int> genreCount = {};
    final Map<String, int> genreWatched = {};
    for (final m in movies) {
      genreCount[m.genre] = (genreCount[m.genre] ?? 0) + 1;
      if (m.watched) {
        genreWatched[m.genre] = (genreWatched[m.genre] ?? 0) + 1;
      }
    }
    final sortedGenres = genreCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    String pct(int part, int of) =>
        of > 0 ? '${(part / of * 100).round()}%' : '0%';

    final body = total == 0
        ? const Center(child: Text('Nenhum filme cadastrado ainda.'))
        : Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Progresso geral ──────────────────────────────
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Progresso geral',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              pct(watched, total),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _AnimatedBar(value: watchPercent, minHeight: 10),
                        const SizedBox(height: 6),
                        Text(
                          '$watched de $total filme${total != 1 ? 's' : ''} assistido${watched != 1 ? 's' : ''}',
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // ── Cards de resumo ──────────────────────────────
                _StatCard(
                  label: 'Total de filmes',
                  value: '$total',
                  icon: Icons.movie,
                  color: Colors.blue,
                ),
                const SizedBox(height: 10),
                _StatCard(
                  label: 'Assistidos',
                  value: '$watched',
                  subtitle: pct(watched, total),
                  icon: Icons.check_circle,
                  color: Colors.green,
                ),
                const SizedBox(height: 10),
                _StatCard(
                  label: 'Não assistidos',
                  value: '$unwatched',
                  subtitle: pct(unwatched, total),
                  icon: Icons.watch_later_outlined,
                  color: Colors.orange,
                ),
                const SizedBox(height: 24),

                // ── Por gênero ───────────────────────────────────
                const Text(
                  'Por gênero',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: sortedGenres.length,
                    itemBuilder: (context, index) {
                      final entry = sortedGenres[index];
                      final genreTotal = entry.value;
                      final genreW = genreWatched[entry.key] ?? 0;
                      final genreUnwatched = genreTotal - genreW;
                      final fraction =
                          genreTotal > 0 ? genreW / genreTotal : 0.0;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  entry.key,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  '$genreTotal filme${genreTotal != 1 ? 's' : ''}',
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 12),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            _AnimatedBar(value: fraction),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                _GenreTag(
                                    count: genreW,
                                    label: 'assistido',
                                    color: Colors.green),
                                const SizedBox(width: 8),
                                _GenreTag(
                                    count: genreUnwatched,
                                    label: 'pendente',
                                    color: Colors.orange),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );

    if (embedded) return body;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estatísticas'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              switch (value) {
                case 'about':
                  Navigator.pushNamed(context, '/about');
                case 'logout':
                  try {
                    final authVM = context.read<AuthViewModel>();
                    final movieVM = context.read<MovieViewModel>();
                    final genreVM = context.read<GenreViewModel>();
                    await authVM.logout();
                    movieVM.clearCurrentUser();
                    genreVM.clearCurrentUser();
                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/', (route) => false);
                    }
                  } catch (_) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Erro ao sair da conta.')),
                      );
                    }
                  }
              }
            },
            itemBuilder: (context) => [
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
      body: SafeArea(child: body),
    );
  }
}

/// Barra de progresso que anima de 0 até o valor real ao ser construída.
class _AnimatedBar extends StatelessWidget {
  final double value;
  final double minHeight;

  const _AnimatedBar({required this.value, this.minHeight = 8});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOut,
      builder: (context, v, _) => LinearProgressIndicator(
        value: v,
        minHeight: minHeight,
        borderRadius: BorderRadius.circular(minHeight / 2),
        color: Colors.green,
        backgroundColor: Colors.white24,
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Accent bar lateral com gradiente da cor do ícone
            Container(
              width: 4,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [color, color.withValues(alpha: 0.3)],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Icon(icon, color: color, size: 32),
                    const SizedBox(width: 16),
                    Expanded(child: Text(label)),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          value,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                        if (subtitle != null)
                          Text(
                            subtitle!,
                            style: TextStyle(
                              fontSize: 12,
                              color: color.withValues(alpha: 0.7),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GenreTag extends StatelessWidget {
  final int count;
  final String label;
  final Color color;

  const _GenreTag({
    required this.count,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: count > 0 ? color : Colors.white24,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$count $label${count != 1 ? 's' : ''}',
          style: TextStyle(
            fontSize: 11,
            color: count > 0 ? color : Colors.grey,
          ),
        ),
      ],
    );
  }
}
