import 'package:flutter/material.dart';

class BottomNavigation extends StatelessWidget {
  const BottomNavigation({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.isFrench,
    required this.newPigeonCount,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final bool isFrench;
  final int newPigeonCount;

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
        NavigationDestination(
          icon: Badge(
            key: const ValueKey('pigeondex-new-badge'),
            isLabelVisible: newPigeonCount > 0,
            label: Text('$newPigeonCount'),
            child: const Icon(Icons.menu_book_outlined),
          ),
          selectedIcon: Badge(
            isLabelVisible: newPigeonCount > 0,
            label: Text('$newPigeonCount'),
            child: const Icon(Icons.menu_book),
          ),
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
