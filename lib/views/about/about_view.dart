import 'package:flutter/material.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sobre')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset('assets/images/framy_logo.png', height: 120),
            const SizedBox(height: 16),
            Text(
              'Framy',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Versão 1.0.0', style: TextStyle(color: Colors.grey)),
            const Divider(height: 40),
            _Section(
              title: 'Objetivo',
              content:
                  'Aplicativo para gerenciamento de filmes. Permite cadastrar títulos com informações básicas, '
                  'adicionar capa e controlar quais filmes já foram assistidos.',
            ),
            const Divider(height: 40),
            _Section(
              title: 'Equipe de Desenvolvimento',
              content: 'Ícaro Costa Pavan\nJeferson Tomaz Querino',
            ),
            const Divider(height: 40),
            _InfoRow(label: 'Disciplina', value: 'Desenvolvimento Mobile II'),
            const SizedBox(height: 8),
            _InfoRow(label: 'Instituição', value: 'UNAERP'),
            const SizedBox(height: 8),
            _InfoRow(label: 'Professor', value: 'Samuel Oliva'),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String content;
  const _Section({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(content),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
        Expanded(child: Text(value)),
      ],
    );
  }
}
