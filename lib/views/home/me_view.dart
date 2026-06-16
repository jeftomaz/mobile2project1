import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/movie_viewmodel.dart';
import '../specific/movie_stats_view.dart';
import 'home_actions.dart';

/// **Eu** — a identidade cinéfila. A coleção vira retrato, não inventário: um
/// manifesto pessoal no topo, seguido do perfil e das estatísticas como
/// "retrato de gosto".
class MeView extends StatelessWidget {
  const MeView({super.key});

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final user = authVM.currentUser;
    final profile = authVM.profile;
    final movieVM = context.watch<MovieViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Eu'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Editar perfil',
            onPressed: () => Navigator.pushNamed(context, '/profile/edit'),
          ),
          const AppOverflowMenu(),
        ],
      ),
      body: user == null
          ? const Center(child: Text('Nenhum usuário autenticado.'))
          : SingleChildScrollView(
              child: Column(
                children: [
                  _ProfileBanner(photoUrl: profile?.photoUrl),
                  const SizedBox(height: 16),
                  Text(
                    profile?.name ?? user.displayName ?? 'Usuário desconhecido',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (profile?.username != null &&
                      profile!.username.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      '@${profile.username}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _Manifesto(movies: movieVM.movies),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
                    child: Column(
                      children: [
                        _InfoTile(
                          icon: Icons.email,
                          label: 'E-mail',
                          value: profile?.email ?? user.email ?? '-',
                        ),
                        const SizedBox(height: 12),
                        _InfoTile(
                          icon: Icons.phone,
                          label: 'Telefone',
                          value: profile?.phone ?? 'Não informado',
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  // Estatísticas absorvidas em "Eu" como retrato de gosto.
                  const MovieStatsView(embedded: true),
                ],
              ),
            ),
    );
  }
}

/// A frase-manifesto: "Você assistiu X filmes · Y gêneros · sua era favorita é
/// os anos 90", derivada do acervo do usuário.
class _Manifesto extends StatelessWidget {
  final List movies;
  const _Manifesto({required this.movies});

  @override
  Widget build(BuildContext context) {
    final watched = movies.where((m) => m.watched).toList();
    final genres = movies.map((m) => m.genre).toSet().length;

    // Década favorita: moda dos anos dos filmes assistidos.
    String? era;
    if (watched.isNotEmpty) {
      final decades = <int, int>{};
      for (final m in watched) {
        final decade = (m.year ~/ 10) * 10;
        decades[decade] = (decades[decade] ?? 0) + 1;
      }
      final top = decades.entries.reduce((a, b) => a.value >= b.value ? a : b);
      era = _decadeLabel(top.key);
    }

    final parts = <String>[
      'Você assistiu ${watched.length} filme${watched.length != 1 ? 's' : ''}',
      if (genres > 0) '$genres gênero${genres != 1 ? 's' : ''}',
      if (era != null) 'sua era favorita é $era',
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.25),
            Theme.of(context).colorScheme.surface,
          ],
        ),
      ),
      child: Text(
        '${parts.join(' · ')}.',
        style: const TextStyle(fontSize: 15, height: 1.4),
      ),
    );
  }

  String _decadeLabel(int decade) {
    if (decade >= 2000) return 'os anos $decade';
    final short = decade % 100; // 90, 80...
    return 'os anos $short';
  }
}

/// Banner de perfil: faixa com gradiente vermelho → preto e o avatar
/// sobreposto na borda inferior.
class _ProfileBanner extends StatelessWidget {
  final String? photoUrl;
  const _ProfileBanner({this.photoUrl});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 215,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 160,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFBF1506), Color(0xFF0D0D0D)],
              ),
            ),
          ),
          Positioned(
            top: 105,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Color(0xFF0D0D0D),
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 55,
                  backgroundColor: const Color(0xFF1A1A1A),
                  backgroundImage: photoUrl != null
                      ? NetworkImage(photoUrl!)
                      : null,
                  child: photoUrl == null
                      ? const Icon(Icons.person, size: 60)
                      : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, size: 26),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
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
