import 'package:flutter/material.dart';
import 'now_view.dart';
import 'diary_view.dart';
import 'me_view.dart';

/// Casca dos três mundos do Framy: **Agora** (a entrada-capa e a fila),
/// **Diário** (a timeline do que já viu) e **Eu** (a identidade cinéfila).
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [NowView(), DiaryView(), MeView()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) =>
            setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.local_movies_outlined),
            selectedIcon: Icon(Icons.local_movies),
            label: 'Agora',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_stories_outlined),
            selectedIcon: Icon(Icons.auto_stories),
            label: 'Diário',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Eu',
          ),
        ],
      ),
    );
  }
}
