import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/movie.dart';
import '../../viewmodels/movie_viewmodel.dart';
import '../../viewmodels/genre_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import 'omdb_picker_dialog.dart';

class AddMovieView extends StatefulWidget {
  const AddMovieView({super.key});

  @override
  State<AddMovieView> createState() => _AddMovieViewState();
}

class _AddMovieViewState extends State<AddMovieView> {
  final _titleController = TextEditingController();
  final _yearController = TextEditingController();
  final _searchController = TextEditingController();
  String? _selectedGenre;
  String? _posterUrl;
  bool _isSearching = false;
  // Define em qual mundo o filme entra: fila ("Quero ver") ou diário ("Já vi").
  bool _alreadyWatched = false;

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
            'Chave da OMDb não configurada. Adicione OMDB_API_KEY no arquivo .env.',
          ),
        ),
      );
      return;
    }

    setState(() => _isSearching = true);
    try {
      final candidates = await movieVM.searchOmdbCandidates(query);
      if (!context.mounted) return;

      if (candidates.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nenhum filme encontrado na OMDb.')),
        );
        return;
      }

      OmdbSearchItem selected;
      if (candidates.length == 1) {
        selected = candidates.first;
      } else {
        setState(() => _isSearching = false);
        final picked = await showDialog<OmdbSearchItem>(
          context: context,
          builder: (_) => OmdbPickerDialog(candidates: candidates),
        );
        if (picked == null || !context.mounted) return;
        selected = picked;
        setState(() => _isSearching = true);
      }

      final result = await movieVM.fetchOmdbById(selected.imdbId);
      if (!context.mounted) return;

      if (result == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível obter os detalhes do filme.')),
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
      if (mounted) setState(() => _isSearching = false);
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

    final uid = context.read<AuthViewModel>().currentUser?.uid;
    if (uid == null) return;

    final movie = Movie(
      id: '',
      userId: uid,
      title: title,
      year: year,
      genre: _selectedGenre!,
      posterUrl: _posterUrl,
      status: _alreadyWatched ? MovieStatus.watched : MovieStatus.wantToWatch,
      watchedAt: _alreadyWatched ? DateTime.now() : null,
    );

    try {
      await context.read<MovieViewModel>().addMovie(movie);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Filme adicionado com sucesso!')),
      );
      Navigator.pop(context);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao salvar filme. Tente novamente.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final genres = context.watch<GenreViewModel>().genreNames;

    if (_selectedGenre != null && genres.isNotEmpty && !genres.contains(_selectedGenre)) {
      _selectedGenre = genres.firstWhere(
        (g) => g.toLowerCase() == _selectedGenre!.toLowerCase(),
        orElse: () => genres.first,
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Adicionar Filme')),
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
                      labelText: 'Buscar na OMDb',
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
            const SizedBox(height: 20),
            // Em qual mundo o filme entra.
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Onde adicionar?',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<bool>(
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
                selected: {_alreadyWatched},
                onSelectionChanged: (s) =>
                    setState(() => _alreadyWatched = s.first),
                showSelectedIcon: false,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _handleSave(context),
                child: const Text('Salvar'),
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
