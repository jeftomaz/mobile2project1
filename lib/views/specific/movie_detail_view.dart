import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/date_format.dart';
import '../../models/movie.dart';
import '../../models/review.dart';
import '../../repositories/review_repository.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/movie_viewmodel.dart';
import '../../widgets/movie_poster.dart';
import '../home/home_actions.dart';
import 'edit_movie_view.dart';

/// Página de diário do filme: em vez de metadados + formulário, uma página
/// editorial — pôster gigante, sua nota em destaque, sua resenha como texto de
/// revista e a pergunta central "o que você sentiu?".
class MovieDetailView extends StatefulWidget {
  final Movie movie;
  const MovieDetailView({super.key, required this.movie});

  @override
  State<MovieDetailView> createState() => _MovieDetailViewState();
}

class _MovieDetailViewState extends State<MovieDetailView> {
  final _commentController = TextEditingController();
  int _selectedRating = 5;
  bool _isSaving = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _setStatus(BuildContext context, Movie movie, bool watched) {
    final vm = context.read<MovieViewModel>();
    return watched ? vm.markWatched(movie) : vm.markWantToWatch(movie);
  }

  Future<void> _saveReview(BuildContext context, Movie movie) async {
    final uid = context.read<AuthViewModel>().currentUser?.uid;
    if (uid == null) return;

    setState(() => _isSaving = true);
    try {
      final repo = context.read<ReviewRepository>();
      if (await repo.hasReview(uid, movie.id)) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Você já avaliou este filme.')),
        );
        return;
      }
      final review = Review(
        id: '',
        userId: uid,
        movieId: movie.id,
        rating: _selectedRating,
        comment: _commentController.text.trim(),
      );
      await repo.addReview(review);
      if (!context.mounted) return;
      _commentController.clear();
      setState(() => _selectedRating = 5);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Avaliação salva!')),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao salvar avaliação.')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Observa o ViewModel para refletir mudanças de status/data ao vivo,
    // caindo de volta no snapshot recebido caso o filme já tenha sido removido.
    final movies = context.watch<MovieViewModel>().movies;
    final movie = movies.firstWhere(
      (m) => m.id == widget.movie.id,
      orElse: () => widget.movie,
    );
    final uid = context.read<AuthViewModel>().currentUser?.uid ?? '';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Editar',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => EditMovieView(movie: movie)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Remover',
            onPressed: () async {
              final removed = await confirmDeleteMovie(context, movie);
              if (removed && context.mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ImmersiveHeader(movie: movie),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Seletor de estado: fila ("Quero ver") x diário ("Já vi").
                  _StatusSelector(
                    watched: movie.watched,
                    onChanged: (watched) => _setStatus(context, movie, watched),
                  ),
                  const SizedBox(height: 24),

                  // A pergunta central.
                  Text(
                    'O que você sentiu?',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Lista de avaliações em tempo real.
                  StreamBuilder<List<Review>>(
                    stream: context
                        .read<ReviewRepository>()
                        .watchReviews(uid, movie.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        );
                      }
                      if (snapshot.hasError) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            'Erro ao carregar avaliações.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        );
                      }
                      final reviews = snapshot.data ?? [];
                      if (reviews.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            'Você ainda não escreveu sobre este filme.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        );
                      }
                      // ListView (RF005) recuperando a coleção `avaliacoes` em
                      // tempo real; shrinkWrap pois vive dentro de um scroll.
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: reviews.length,
                        itemBuilder: (context, index) =>
                            _ReviewTile(review: reviews[index]),
                      );
                    },
                  ),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text(
                    'Registrar sua impressão',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  // Seletor de nota.
                  Row(
                    children: [
                      const Text('Nota: '),
                      ...List.generate(5, (i) {
                        final star = i + 1;
                        return IconButton(
                          icon: Icon(
                            star <= _selectedRating
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                          ),
                          onPressed: () =>
                              setState(() => _selectedRating = star),
                          constraints: const BoxConstraints(minWidth: 36),
                          padding: EdgeInsets.zero,
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      labelText: 'Sua resenha (opcional)',
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving
                          ? null
                          : () => _saveReview(context, movie),
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Salvar Avaliação'),
                    ),
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

/// Alterna o filme entre a fila ("Quero ver") e o diário ("Já vi").
class _StatusSelector extends StatelessWidget {
  final bool watched;
  final ValueChanged<bool> onChanged;

  const _StatusSelector({required this.watched, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<bool>(
      segments: const [
        ButtonSegment(
          value: false,
          icon: Icon(Icons.bookmark_outline),
          label: Text('Quero ver'),
        ),
        ButtonSegment(
          value: true,
          icon: Icon(Icons.check_circle_outline),
          label: Text('Já vi'),
        ),
      ],
      selected: {watched},
      onSelectionChanged: (s) => onChanged(s.first),
      showSelectedIcon: false,
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final Review review;
  const _ReviewTile({required this.review});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ...List.generate(
                  5,
                  (i) => Icon(
                    i < review.rating ? Icons.star : Icons.star_border,
                    size: 18,
                    color: Colors.amber,
                  ),
                ),
                const Spacer(),
                Text(
                  DateFormatPt.shortDate(review.createdAt),
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
            if (review.comment.isNotEmpty) ...[
              const SizedBox(height: 10),
              // Resenha em serifada elegante, com ar de crítica de cinema.
              Text(
                review.comment,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 17,
                  height: 1.5,
                  fontStyle: FontStyle.italic,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Header imersivo: pôster em full-width desfocado como fundo, gradiente
/// escuro por cima e o pôster nítido (Hero) com título, chips e — quando no
/// diário — a data em que foi assistido.
class _ImmersiveHeader extends StatelessWidget {
  final Movie movie;
  const _ImmersiveHeader({required this.movie});

  @override
  Widget build(BuildContext context) {
    const headerHeight = 360.0;
    final poster = movie.posterUrl;

    return SizedBox(
      height: headerHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Backdrop desfocado.
          if (poster != null)
            ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Image.network(
                poster,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    const ColoredBox(color: Color(0xFF1A1A1A)),
              ),
            )
          else
            const ColoredBox(color: Color(0xFF1A1A1A)),

          // Gradiente escuro sobre o backdrop.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black54, Color(0xFF0D0D0D)],
                stops: [0.0, 0.95],
              ),
            ),
          ),

          // Pôster nítido + título + chips.
          Positioned(
            left: 20,
            right: 20,
            bottom: 16,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                MoviePoster(movie: movie, width: 120, height: 180),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        movie.title,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(height: 1.0),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _MetaChip(
                            icon: Icons.calendar_today,
                            label: '${movie.year}',
                          ),
                          _MetaChip(
                            icon: Icons.local_movies_outlined,
                            label: movie.genre,
                          ),
                          if (movie.watched && movie.watchedAt != null)
                            _MetaChip(
                              icon: Icons.event_available,
                              label: 'Visto em ${DateFormatPt.shortDate(movie.watchedAt!)}',
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Chip de metadado com ícone, borda sutil e fundo surface.
class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _MetaChip({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final fg = color ?? Colors.white70;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12, color: fg)),
        ],
      ),
    );
  }
}
