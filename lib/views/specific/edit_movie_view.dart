import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/movie.dart';
import '../../viewmodels/movie_viewmodel.dart';
import '../../viewmodels/genre_viewmodel.dart';

class EditMovieView extends StatefulWidget {
  final Movie movie;
  const EditMovieView({super.key, required this.movie});

  @override
  State<EditMovieView> createState() => _EditMovieViewState();
}

class _EditMovieViewState extends State<EditMovieView> {
  late final TextEditingController _titleController;
  late final TextEditingController _yearController;
  final _searchController = TextEditingController();
  String? _selectedGenre;
  String? _posterUrl;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.movie.title);
    _yearController = TextEditingController(text: widget.movie.year.toString());
    _selectedGenre = widget.movie.genre;
    _posterUrl = widget.movie.posterUrl;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _yearController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchOmdb(BuildContext context) async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    final movieVM = context.read<MovieViewModel>();
    if (!movieVM.omdbConfigured) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Chave da OMDb não configurada. Consulte lib/services/omdb_service.dart.',
          ),
        ),
      );
      return;
    }

    setState(() => _isSearching = true);
    try {
      final result = await movieVM.searchOmdb(query);
      if (!context.mounted) return;

      if (result == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nenhum filme encontrado na OMDb.')),
        );
        return;
      }

      final genreVM = context.read<GenreViewModel>();
      final knownGenres = genreVM.genreNames;
      final matchedGenre = knownGenres.firstWhere(
        (g) => g.toLowerCase() == result.genre.toLowerCase(),
        orElse: () => knownGenres.isNotEmpty ? knownGenres.first : result.genre,
      );

      setState(() {
        _titleController.text = result.title;
        _yearController.text = result.year.toString();
        _selectedGenre = matchedGenre;
        _posterUrl = result.posterUrl;
      });
    } finally {
      setState(() => _isSearching = false);
    }
  }

  Future<void> _handleSave(BuildContext context) async {
    final title = _titleController.text.trim();
    final year = int.tryParse(_yearController.text.trim());

    if (title.isEmpty || year == null || _selectedGenre == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos.')),
      );
      return;
    }

    final updated = Movie(
      id: widget.movie.id,
      userId: widget.movie.userId,
      title: title,
      year: year,
      genre: _selectedGenre!,
      posterUrl: _posterUrl,
      watched: widget.movie.watched,
      createdAt: widget.movie.createdAt,
    );

    try {
      await context.read<MovieViewModel>().updateMovie(updated);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Filme atualizado com sucesso!')),
      );
      Navigator.pop(context);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao atualizar filme. Tente novamente.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final genres = context.watch<GenreViewModel>().genreNames;

    if (_selectedGenre != null && !genres.contains(_selectedGenre)) {
      _selectedGenre = null;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Editar Filme')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Busca OMDb
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Re-buscar na OMDb (opcional)',
                      prefixIcon: Icon(Icons.search),
                    ),
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _searchOmdb(context),
                  ),
                ),
                const SizedBox(width: 8),
                _isSearching
                    ? const SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () => _searchOmdb(context),
                        tooltip: 'Buscar',
                      ),
              ],
            ),
            const SizedBox(height: 16),

            // Capa
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _posterUrl != null
                  ? Image.network(
                      _posterUrl!,
                      height: 150,
                      width: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) =>
                          _posterPlaceholder(),
                    )
                  : _posterPlaceholder(),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Título'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _yearController,
              decoration: const InputDecoration(labelText: 'Ano de Lançamento'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              key: ValueKey(_selectedGenre),
              initialValue: _selectedGenre,
              hint: const Text('Selecione o Gênero'),
              items: genres
                  .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                  .toList(),
              onChanged: (value) => setState(() => _selectedGenre = value),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _handleSave(context),
                child: const Text('Salvar Alterações'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _posterPlaceholder() => Container(
    height: 150,
    width: 100,
    color: Colors.grey[800],
    child: const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey),
        Text('Sem capa', style: TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    ),
  );
}
