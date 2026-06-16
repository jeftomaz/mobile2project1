import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/genre.dart';
import '../../viewmodels/genre_viewmodel.dart';

/// Diálogo de gerenciamento de gêneros personalizados do usuário.
class GenreManagerDialog extends StatefulWidget {
  const GenreManagerDialog({super.key});

  @override
  State<GenreManagerDialog> createState() => _GenreManagerDialogState();
}

class _GenreManagerDialogState extends State<GenreManagerDialog> {
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
                    await context.read<GenreViewModel>().addGenre(
                      _addController.text,
                    );
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
                      .map(
                        (g) => ListTile(
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
                                onPressed: () => context
                                    .read<GenreViewModel>()
                                    .removeGenre(g.id),
                              ),
                            ],
                          ),
                        ),
                      )
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
