import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import '../../models/movie.dart';
import '../../viewmodels/movie_viewmodel.dart';

class EditMovieView extends StatefulWidget {
  final Movie movie;
  const EditMovieView({super.key, required this.movie});

  @override
  State<EditMovieView> createState() => _EditMovieViewState();
}

class _EditMovieViewState extends State<EditMovieView> {
  late final TextEditingController _titleController;
  late final TextEditingController _yearController;
  String? _selectedGenre;
  Uint8List? _coverBytes;

  final List<String> _genres = [
    'Ação',
    'Comédia',
    'Drama',
    'Terror',
    'Ficção Científica',
    'Animação',
  ];

  @override
  void initState() {
    super.initState();
    // Pré-preenche os campos com os dados do filme existente
    _titleController = TextEditingController(text: widget.movie.title);
    _yearController = TextEditingController(text: widget.movie.year.toString());
    _selectedGenre = widget.movie.genre;
    _coverBytes = widget.movie.coverBytes;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() => _coverBytes = bytes);
    }
  }

  void _handleSave(BuildContext context) {
    final title = _titleController.text.trim();
    final year = int.tryParse(_yearController.text.trim());

    if (title.isEmpty || year == null || _selectedGenre == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos.')),
      );
      return;
    }

    // Cria um Movie atualizado mantendo o mesmo id e o status watched
    final updated = Movie(
      id: widget.movie.id,
      title: title,
      year: year,
      genre: _selectedGenre!,
      coverBytes: _coverBytes,
      watched: widget.movie.watched,
    );

    context.read<MovieViewModel>().updateMovie(updated);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Filme atualizado com sucesso!')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Filme')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Preview / seleção de capa
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 150,
                width: 100,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _coverBytes != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(_coverBytes!, fit: BoxFit.cover),
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate,
                            size: 40,
                            color: Colors.grey,
                          ),
                          Text(
                            'Alterar capa',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
              ),
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
              value: _selectedGenre,
              hint: const Text('Selecione o Gênero'),
              items: _genres
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
}
