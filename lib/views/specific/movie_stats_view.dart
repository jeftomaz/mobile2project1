import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

    final Map<String, int> genreCount = {};
    for (final m in movies) {
      genreCount[m.genre] = (genreCount[m.genre] ?? 0) + 1;
    }
    final sortedGenres = genreCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final body = Padding(
      padding: const EdgeInsets.all(16),
      child: total == 0
          ? const Center(child: Text('Nenhum filme cadastrado ainda.'))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatCard(
                  label: 'Total de filmes',
                  value: '$total',
                  icon: Icons.movie,
                  color: Colors.blue,
                ),
                const SizedBox(height: 12),
                _StatCard(
                  label: 'Assistidos',
                  value: '$watched',
                  icon: Icons.check_circle,
                  color: Colors.green,
                ),
                const SizedBox(height: 12),
                _StatCard(
                  label: 'Não assistidos',
                  value: '$unwatched',
                  icon: Icons.watch_later_outlined,
                  color: Colors.orange,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Por gênero',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: sortedGenres.length,
                    itemBuilder: (context, index) {
                      final entry = sortedGenres[index];
                      final percent = entry.value / total;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(entry.key),
                                Text('${entry.value}'),
                              ],
                            ),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: percent,
                              minHeight: 8,
                              borderRadius: BorderRadius.circular(4),
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
      appBar: AppBar(title: const Text('Estatísticas')),
      body: body,
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: color, size: 32),
        title: Text(label),
        trailing: Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }
}
