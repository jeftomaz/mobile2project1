import 'package:flutter/material.dart';
import '../../models/movie.dart';

class MovieDetailView extends StatelessWidget {
  final Movie movie;
  const MovieDetailView({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(movie.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: movie.coverBytes != null
                  ? Image.memory(
                      movie.coverBytes!,
                      height: 250,
                      width: 170,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      height: 250,
                      width: 170,
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.movie,
                        size: 60,
                        color: Colors.grey,
                      ),
                    ),
            ),
            const SizedBox(height: 24),
            Text(
              movie.title,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            _DetailRow(label: 'Ano', value: movie.year.toString()),
            const SizedBox(height: 8),
            _DetailRow(label: 'Gênero', value: movie.genre),
            const SizedBox(height: 8),
            _DetailRow(
              label: 'Status',
              value: movie.watched ? 'Assistido' : 'Não assistido',
              valueColor: movie.watched ? Colors.green : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _DetailRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(value, style: TextStyle(color: valueColor)),
      ],
    );
  }
}
