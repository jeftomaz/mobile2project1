import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/movie_viewmodel.dart';
import '../../viewmodels/genre_viewmodel.dart';

class AccountView extends StatelessWidget {
  const AccountView({super.key});

  void _handleLogout(BuildContext context) async {
    final authVM = context.read<AuthViewModel>();
    final movieVM = context.read<MovieViewModel>();
    final genreVM = context.read<GenreViewModel>();

    try {
      await authVM.logout();
      movieVM.clearCurrentUser();
      genreVM.clearCurrentUser();

      if (!context.mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao sair da conta.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final user = authVM.currentUser;
    final profile = authVM.profile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minha Conta'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Editar perfil',
            onPressed: () => Navigator.pushNamed(context, '/profile/edit'),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'about':
                  Navigator.pushNamed(context, '/about');
                  break;
                case 'logout':
                  _handleLogout(context);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'about',
                child: ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('Sobre'),
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Sair'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: user == null
          ? const Center(
              child: Text('Nenhum usuário autenticado.', style: TextStyle(fontSize: 16)),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  _ProfileBanner(photoUrl: profile?.photoUrl),
                  const SizedBox(height: 16),
                  Text(
                    profile?.name ?? user.displayName ?? 'Usuário desconhecido',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                    child: Column(
                      children: [
                        _InfoTile(
                          icon: Icons.email,
                          label: 'E-mail',
                          value: profile?.email ?? user.email ?? '-',
                        ),
                        const SizedBox(height: 16),
                        _InfoTile(
                          icon: Icons.phone,
                          label: 'Telefone',
                          value: profile?.phone ?? 'Não informado',
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

/// Banner de perfil: faixa com gradiente vermelho → preto e o avatar
/// posicionado sobreposto na borda inferior (metade dentro, metade fora).
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
                  backgroundImage:
                      photoUrl != null ? NetworkImage(photoUrl!) : null,
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
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
