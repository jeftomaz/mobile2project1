import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/date_format.dart';
import '../../models/movie.dart';
import '../../repositories/movie_repository.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/movie_poster.dart';
import '../specific/movie_detail_view.dart';

/// **Diário** — a espinha dorsal temporal. Uma timeline vertical "assisti isto,
/// depois aquilo", agrupada por mês/ano, com o pôster como marco. Filmes não
/// são itens numa tabela: são memórias datadas.
///
/// RF005: a recuperação dos dados é feita com a classe [StreamBuilder] lendo
/// diretamente o stream da coleção `filmes` do Firestore e exibindo-os em
/// tempo real num [ListView].
class DiaryView extends StatelessWidget {
  const DiaryView({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.watch<AuthViewModel>().currentUser?.uid;
    final repo = context.read<MovieRepository>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diário'),
        automaticallyImplyLeading: false,
      ),
      body: uid == null
          ? const Center(child: Text('Nenhum usuário autenticado.'))
          : StreamBuilder<List<Movie>>(
              stream: repo.watchMovies(uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const _DiaryError();
                }

                // Apenas o que já foi assistido, ordenado pela data do diário.
                final watched =
                    (snapshot.data ?? []).where((m) => m.watched).toList()
                      ..sort((a, b) => b.diaryDate.compareTo(a.diaryDate));

                if (watched.isEmpty) return const _EmptyDiary();

                final rows = _buildRows(watched);

                return Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                        child: Text(
                          '${watched.length} filme${watched.length != 1 ? 's' : ''} assistido${watched.length != 1 ? 's' : ''}',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: rows.length,
                        itemBuilder: (context, index) {
                          final row = rows[index];
                          return switch (row) {
                            _MonthRow(:final label) => _MonthHeader(label: label),
                            _EntryRow(:final movie, :final isLast) =>
                              _DiaryEntry(movie: movie, isLast: isLast),
                          };
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  /// Achata a lista assistida em linhas de cabeçalho (mês/ano) + entradas,
  /// preservando a ordem decrescente para o [ListView].
  List<_DiaryRow> _buildRows(List<Movie> watched) {
    final rows = <_DiaryRow>[];
    DateTime? currentMonth;
    for (var i = 0; i < watched.length; i++) {
      final movie = watched[i];
      final d = movie.diaryDate;
      final month = DateTime(d.year, d.month);
      if (currentMonth == null || month != currentMonth) {
        currentMonth = month;
        rows.add(_MonthRow(DateFormatPt.monthYear(month)));
      }
      // É o último da timeline se o próximo for de outro mês (ou não existir).
      final isLastOfMonth = i == watched.length - 1 ||
          DateTime(watched[i + 1].diaryDate.year,
                  watched[i + 1].diaryDate.month) !=
              month;
      rows.add(_EntryRow(movie, isLastOfMonth));
    }
    return rows;
  }
}

sealed class _DiaryRow {}

class _MonthRow extends _DiaryRow {
  final String label;
  _MonthRow(this.label);
}

class _EntryRow extends _DiaryRow {
  final Movie movie;
  final bool isLast;
  _EntryRow(this.movie, this.isLast);
}

/// Cabeçalho de mês/ano.
class _MonthHeader extends StatelessWidget {
  final String label;
  const _MonthHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        label,
        style: Theme.of(context).textTheme.headlineSmall
            ?.copyWith(color: Theme.of(context).colorScheme.primary),
      ),
    );
  }
}

/// Uma entrada da timeline: a data como protagonista, o pôster como marco e a
/// linha vertical conectando os momentos.
class _DiaryEntry extends StatelessWidget {
  final Movie movie;
  final bool isLast;

  const _DiaryEntry({required this.movie, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final date = movie.diaryDate;

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => MovieDetailView(movie: movie)),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Trilho da timeline com o ponto do marco.
            SizedBox(
              width: 40,
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: 2,
                      color: isLast ? Colors.transparent : Colors.white12,
                    ),
                  ),
                ],
              ),
            ),
            // Pôster como marco visual.
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: MoviePoster(movie: movie, width: 56, height: 84),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormatPt.longDate(date),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 12,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      movie.title,
                      style: Theme.of(context).textTheme.titleLarge
                          ?.copyWith(fontSize: 20, height: 1.0),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${movie.genre} • ${movie.year}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }
}

class _EmptyDiary extends StatelessWidget {
  const _EmptyDiary();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_stories_outlined,
                size: 64, color: Colors.white24),
            const SizedBox(height: 16),
            Text(
              'Seu diário está em branco',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'Marque um filme como "Já vi" e ele vira uma memória datada aqui.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

/// Estado de falha na recuperação (RF005: feedback + possibilidade de retry).
/// O stream do Firestore se reconecta sozinho assim que a conexão volta.
class _DiaryError extends StatelessWidget {
  const _DiaryError();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.cloud_off, size: 56, color: Colors.white24),
            SizedBox(height: 12),
            Text(
              'Não foi possível carregar seu diário.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 4),
            Text(
              'Verifique sua conexão — a lista atualiza sozinha ao reconectar.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
