import 'package:flutter/material.dart';
import '../../services/omdb_service.dart';

class OmdbPickerDialog extends StatelessWidget {
  final List<OmdbSearchItem> candidates;
  const OmdbPickerDialog({super.key, required this.candidates});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Selecionar Filme'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: candidates.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final item = candidates[index];
            return ListTile(
              leading: item.posterUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.network(
                        item.posterUrl!,
                        width: 36,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) =>
                            const SizedBox(width: 36, child: Icon(Icons.movie)),
                      ),
                    )
                  : const SizedBox(width: 36, child: Icon(Icons.movie)),
              title: Text(item.title),
              subtitle: item.year > 0 ? Text('${item.year}') : null,
              onTap: () => Navigator.pop(context, item),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
      ],
    );
  }
}
