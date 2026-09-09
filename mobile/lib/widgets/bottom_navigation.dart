import 'package:flutter/material.dart';

class BottomNavigation extends StatelessWidget {
  const BottomNavigation({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.isFrench,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final bool isFrench;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.park_outlined),
          selectedIcon: const Icon(Icons.park),
          label: isFrench ? 'Parc' : 'Park',
        ),
        const NavigationDestination(
          icon: Icon(Icons.menu_book_outlined),
          selectedIcon: Icon(Icons.menu_book),
          label: 'Pigeondex',
        ),
        NavigationDestination(
          icon: const Icon(Icons.diamond_outlined),
          selectedIcon: const Icon(Icons.diamond),
          label: isFrench ? 'Trésors' : 'Treasures',
        ),
        NavigationDestination(
          icon: const Icon(Icons.settings_outlined),
          selectedIcon: const Icon(Icons.settings),
          label: isFrench ? 'Paramètres' : 'Settings',
        ),
      ],
    );
  }
}
