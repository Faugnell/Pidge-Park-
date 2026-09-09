import 'package:flutter/material.dart';

import '../collection/pigeon_collection_controller.dart';
import '../game/game_controller.dart';
import '../settings/settings_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_navigation.dart';
import 'park_screen.dart';
import 'pigeondex_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    required this.settingsController,
    required this.pigeonCollectionController,
    required this.gameController,
    super.key,
  });

  final SettingsController settingsController;
  final PigeonCollectionController pigeonCollectionController;
  final GameController gameController;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isFrench = widget.settingsController.isFrench;
    final pages = <Widget>[
      ParkScreen(
        gameController: widget.gameController,
        collectionController: widget.pigeonCollectionController,
        isFrench: isFrench,
        onOpenShop: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => _ShopPage(isFrench: isFrench),
            ),
          );
        },
      ),
      PigeondexScreen(
        controller: widget.pigeonCollectionController,
        isFrench: isFrench,
      ),
      _PlaceholderPage(
        icon: Icons.diamond,
        title: isFrench ? 'Trésors' : 'Treasures',
        message: isFrench
            ? 'Tes trésors apparaîtront ici.'
            : 'Your treasures will appear here.',
      ),
      SettingsScreen(
        controller: widget.settingsController,
        onResetProgress: () async {
          await widget.pigeonCollectionController.resetAllData();
          await widget.gameController.resetAllData();
        },
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: BottomNavigation(
        selectedIndex: _selectedIndex,
        isFrench: isFrench,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
      ),
    );
  }
}

class _ShopPage extends StatelessWidget {
  const _ShopPage({required this.isFrench});

  final bool isFrench;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.placeholderBackground,
      appBar: AppBar(
        backgroundColor: AppColors.placeholderBackground,
        title: Text(isFrench ? 'Boutique' : 'Shop'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.storefront, size: 64, color: AppColors.selected),
              const SizedBox(height: 16),
              Text(
                isFrench
                    ? 'La boutique ouvrira bientôt.'
                    : 'The shop will open soon.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.placeholderBackground,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 56, color: AppColors.selected),
                const SizedBox(height: 16),
                Text(title, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
